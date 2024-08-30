public with sharing class ToolingAPIUtility {
    public static final String endpoint = '/services/data/v51.0/tooling/query/?q=';
    
    public static HttpResponse queryToolingAPI(String query) {

        System.debug('query - ' + query);
        
        String urlString = endpoint + EncodingUtil.urlEncode(query, 'UTF-8');
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        System.debug('urlString - ' + urlString);
        System.debug('baseUrl - ' + baseUrl);

        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(baseUrl + urlString);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        return response;
    }

    public static void createCSV(){

        HttpResponse response = ToolingAPIUtility.queryToolingAPI('Select id, SiteName, EndpointURL, ProtocolMismatch, IsActive, Description  from RemoteProxy');
        System.debug('response - ' + response);
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        List<Object> csvRowList = (List<Object>) jsonResponse.get('records');
        System.debug('jsonResponse - ' + jsonResponse);
        System.debug('records - ' + csvRowList);



        String title = 'Remote_Proxy_List';
        List<String> csvHeaders = new List<String>{'Description', 'EndpointUrl', 'Id', 'IsActive', 'ProtocolMismatch', 'SiteName'};
        String headerRow = String.join(csvHeaders,',') + '\n';
        String concantenatedStr = headerRow;


        Integer i = 0;
        Integer rowListSize = csvRowList.size();
        Integer headerSize = csvHeaders.size();

        for(Object row :csvRowList){
            
            System.debug('row - ' + row);//assuming the rowList is in the correct format and each string in the list is a new record
            
            Map<String, Object> objFieldMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(row));
            objFieldMap.remove( 'attributes' );
            System.debug('objFieldMap - ' + objFieldMap);
            Integer j = 0;
            for(String objField :csvHeaders){
                System.debug('objField - ' + objField);
                System.debug('objFieldMap.get(objField) - ' + objFieldMap.get(objField));
                concantenatedStr += objFieldMap.get(objField) != null ? String.valueOf(objFieldMap.get(objField)) : '';
                j++;
                concantenatedStr += j != headerSize ? ',' : '';//add comma separator
            }
            System.debug('concantenatedStr - ' + concantenatedStr);
            i++;
            if(i != rowListSize) concantenatedStr += '\n';//add new line
        }


        title += '.csv';
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = title; //title of the file
        cv.PathOnClient = title; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(concantenatedStr); //file data
        //insert cv;

        ToolingAPIUtility.sendEmailWithCSV(concantenatedStr);

    }

    public static void sendEmailWithCSV(String CsvData){

        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(CsvData);
        String csvName = 'Remote_Site_Settings.csv';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String userName = UserInfo.getUserName();
        User activeUser = [ Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        String[] toAddresses = new String[]{userEmail};
            String subject = 'Remote Site Settings';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('Here is the List of Attached CSV File');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        if (r[0].success) {
            System.debug('The email was sent successfully.');
            
        } else {
            System.debug('The email failed to send: ' + r[0].errors[0].message);
            
        }
    }

    @AuraEnabled
    public static Boolean updateSiteSettingsByCSV(String fileName){

        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = Metadata_Api.fetchUserSessionId();

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: fileName LIMIT 1];
        System.debug('sr - ' + sr);
        String body = sr.Body.toString();
        System.debug('body - ' + body);
        String[] filelines = body.split('\n');
        List<MetadataService.RemoteSiteSetting> ms = new List<MetadataService.RemoteSiteSetting>();
        for (Integer i=1;i<filelines.size();i++)
        {
            String[] inputvalues = new String[]{};
            inputvalues = filelines[i].split(',');
            System.debug('inputvalues - ' + inputvalues);

            MetadataService.RemoteSiteSetting a = new MetadataService.RemoteSiteSetting();
            a.fullName = inputvalues[5];
            a.disableProtocolSecurity = Boolean.valueOf(inputvalues[4]);
            a.isActive = Boolean.valueOf(inputvalues[3]);
            a.url = inputvalues[1];
            ms.add(a);

        }

        List<MetadataService.UpsertResult> results = service.upsertMetadata(ms);
        System.debug('saveResult.success - ' + results[0].success);

        return results[0].success;
        

    }

}