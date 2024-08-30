public with sharing class Metadata_Api {

    public class resultData{

        @AuraEnabled
        public Boolean IsSuccess;

        @AuraEnabled
        public List<String> Error;
    }

    public class metadataRecord {
        public String transactionType;
        public String metadataType;
        public String fullName;
        public String shortDescription;
        public String value;
        public Boolean protected_x;
        public String mdtName;
        public String mdtRecName;
        public String label;
        public String fieldName;
        public String url;
        public Boolean disableProtocolSecurity;
        public Boolean isActive;
        public String name;
        public String folderName;
        public String uniqueName;
        public String encoding;
        public String type;
        public String style;
        public String content;
        public Boolean available;
        public String objectName;
        public String integrationUser;
        public Boolean includeSessionId;
    }

    @AuraEnabled
    public static resultData updateData(String mdtData){
        
        metadataRecord mrObj = (metadataRecord)JSON.deserializeStrict(mdtData, metadataRecord.class);
        System.debug('mrObj - ' + mrObj);

        MetadataService.SaveResult saveResult;
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = fetchUserSessionId();

        if(mrObj.metadataType == 'customLabel'){

            MetadataService.CustomLabel clObj = new MetadataService.CustomLabel();
            clObj.fullName = mrObj.fullName; //'test_label'
            clObj.language='en_US';
            clObj.protected_x= mrObj.protected_x; //False
            clObj.shortDescription= mrObj.shortDescription; //'test label'
            clObj.value= mrObj.value; //'After Test'    
    
            if(mrObj.transactionType == 'create'){
                List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] { clObj });
                saveResult = results[0];
            } else {
                List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { clObj });
                saveResult = results[0];
            }
            
    
        } else if(mrObj.metadataType == 'customMetadata'){

            MetadataService.CustomMetadata cmdt = new MetadataService.CustomMetadata();
    
            cmdt.fullName = mrObj.mdtName + '.' + mrObj.mdtRecName; //'Integration_End_Point.Get_Contact'
            cmdt.label= mrObj.label; //'Get Contact'
            MetadataService.CustomMetadataValue cmv = new MetadataService.CustomMetadataValue();
            cmv.field = mrObj.fieldName; //'End_Points__c'
            cmv.value = mrObj.value; //'after updation test - https://www.google.com/m8/feeds/contacts/akash.chauhan@cloudanalogy.com/full?alt=json'

            cmdt.values=new MetadataService.CustomMetadataValue[] {cmv};
        
            if(mrObj.transactionType == 'create'){
                List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] { cmdt });
                saveResult = results[0];
            } else {
                List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { cmdt });
                saveResult = results[0];
            }

        } else if(mrObj.metadataType == 'remoteSiteSetting'){

            MetadataService.RemoteSiteSetting remoteObj = new MetadataService.RemoteSiteSetting();
            remoteObj.fullName= mrObj.fullName; //'GoogleContact';
            remoteObj.disableProtocolSecurity= mrObj.disableProtocolSecurity; //false;
            remoteObj.isActive= mrObj.isActive; //true;
            remoteObj.url= mrObj.url; //'https://www.tested.com';

            if(mrObj.transactionType == 'create'){
                List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] { remoteObj });
                saveResult = results[0];
            } else {
                List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { remoteObj });
                saveResult = results[0];
            }

        } else if(mrObj.metadataType == 'emailTemplate'){
            
            MetadataService.EmailTemplate emailObj = new MetadataService.EmailTemplate();
            
            emailObj.name= mrObj.name; //'Send Email after 24 hours when case is open';
            emailObj.fullName = 'unfiled$public/' + mrObj.uniqueName; //'Send_Email_after_24_hours_when_case_is_open';
            emailObj.available= mrObj.available;//true;
            Blob binaryData = Blob.valueOf(mrObj.content);
            emailObj.content= EncodingUtil.base64Encode(binaryData);
            emailObj.encodingKey=  mrObj.encoding; //'ISO-8859-1';
            emailObj.type_x= mrObj.type; //'text';
            emailObj.style= mrObj.style; //'none';
        
            if(mrObj.transactionType == 'create'){
                List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] { emailObj });
                saveResult = results[0];
            } else {
                List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { emailObj });
                saveResult = results[0];
            }

        } else if(mrObj.metadataType == 'outboundMessage'){      
            
            MetadataService.WorkflowOutboundMessage outBoundM = new MetadataService.WorkflowOutboundMessage();
            outBoundM.apiVersion=60.0;
            outBoundM.endpointUrl= mrObj.url; //'https://afterfinallyTested.com';
            outBoundM.fullName= mrObj.objectName + '.' + mrObj.uniqueName; //'Account.test';
            outBoundM.includeSessionId= mrObj.includeSessionId; //false;
            outBoundM.integrationUser= mrObj.integrationUser; //'akash.chauhan@testmetadataapi.com';
            outBoundM.name= mrObj.name; //'test';
            outBoundM.protected_x= mrObj.protected_x; //false;        
    
            if(mrObj.transactionType == 'create'){
                List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] { outBoundM });
                saveResult = results[0];
            } else {
                List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { outBoundM });
                saveResult = results[0];
            }
                
        }

        List<String> messages = new List<String>();

        if(saveResult.errors!=null){
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');

            for(MetadataService.Error error : saveResult.errors) {

                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            }
        }
            
        resultData rd  = new resultData();
        rd.IsSuccess = saveResult.success;
        rd.Error = messages;
        System.debug('rd - ' + rd);
        return rd;
        
    }

    public static String fetchUserSessionId(){
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.GetSessionIdVF;
        // Get the content of the VF page
        String vfContent = reportPage.getContent().toString();
        System.debug('vfContent '+vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
        endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        sessionId = vfContent.substring(startP, endP);
        System.debug('sessionId '+sessionId);
        // Return Session Id
        return sessionId;
    }
    
}