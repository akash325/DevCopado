public with sharing class Metadata_Api_New {
    public class resultData{

        @AuraEnabled
        public Boolean IsSuccess;

        @AuraEnabled
        public List<String> Error;
    }

    public class metadataRecord {
        @InvocableVariable
        public String metadataType;
        @InvocableVariable
        public String fullName;
        @InvocableVariable
        public String shortDescription;
        @InvocableVariable
        public String value;
        @InvocableVariable
        public Boolean protected_x;
        @InvocableVariable
        public String mdtName;
        @InvocableVariable
        public String mdtRecName;
        @InvocableVariable
        public String label;
        @InvocableVariable
        public String fieldName;
        @InvocableVariable
        public String url;
        @InvocableVariable
        public Boolean disableProtocolSecurity;
        @InvocableVariable
        public Boolean isActive;
        @InvocableVariable
        public String name;
        @InvocableVariable
        public String folderName;
        @InvocableVariable
        public String uniqueName;
        @InvocableVariable
        public String encoding;
        @InvocableVariable
        public String type;
        @InvocableVariable
        public String style;
        @InvocableVariable
        public String content;
        @InvocableVariable
        public Boolean available;
        @InvocableVariable
        public String objectName;
        @InvocableVariable
        public String integrationUser;
        @InvocableVariable
        public Boolean includeSessionId;
    }

    @InvocableMethod
    public static List<string> updateData(List<metadataRecord> mrObj){
        
        System.debug('mdtData - ' + mrObj[0]);
        

        MetadataService.SaveResult saveResult;
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        System.debug('service - ' + service);
        System.debug('UserInfo.getSessionId() - ' + UserInfo.getSessionId());
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        

        if(mrObj[0].metadataType == 'customLabel'){

            MetadataService.CustomLabel clObj = new MetadataService.CustomLabel();
            clObj.fullName = mrObj[0].fullName; //'test_label'
            clObj.language='en_US';
            clObj.protected_x= mrObj[0].protected_x; //False
            clObj.shortDescription= mrObj[0].shortDescription; //'test label'
            clObj.value= mrObj[0].value; //'After Test'    
    
            List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { clObj });
            saveResult = results[0];
        
    
        } else if(mrObj[0].metadataType == 'customMetadata'){

            MetadataService.CustomMetadata cmdt = new MetadataService.CustomMetadata();
    
            cmdt.fullName = mrObj[0].mdtName + '.' + mrObj[0].mdtRecName; //'Integration_End_Point.Get_Contact'
            cmdt.label= mrObj[0].label; //'Get Contact'
            MetadataService.CustomMetadataValue cmv = new MetadataService.CustomMetadataValue();
            cmv.field = mrObj[0].fieldName; //'End_Points__c'
            cmv.value = mrObj[0].value; //'after updation test - https://www.google.com/m8/feeds/contacts/akash.chauhan@cloudanalogy.com/full?alt=json'

            cmdt.values=new MetadataService.CustomMetadataValue[] {cmv};
        
            List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { cmdt });
            saveResult = results[0];

        } else if(mrObj[0].metadataType == 'remoteSiteSetting'){

            MetadataService.RemoteSiteSetting remoteObj = new MetadataService.RemoteSiteSetting();
            remoteObj.fullName= mrObj[0].fullName; //'GoogleContact';
            remoteObj.disableProtocolSecurity= mrObj[0].disableProtocolSecurity; //false;
            remoteObj.isActive= mrObj[0].isActive; //true;
            remoteObj.url= mrObj[0].url; //'https://www.tested.com';
            List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { remoteObj });
            saveResult = results[0];

        } else if(mrObj[0].metadataType == 'emailTemplate'){
            
            MetadataService.EmailTemplate emailObj = new MetadataService.EmailTemplate();
            
            emailObj.name= mrObj[0].name; //'Send Email after 24 hours when case is open';
            emailObj.fullName = 'unfiled$public/' + mrObj[0].uniqueName; //'Send_Email_after_24_hours_when_case_is_open';
            emailObj.available= mrObj[0].available;//true;
            Blob binaryData = Blob.valueOf(mrObj[0].content);
            emailObj.content= EncodingUtil.base64Encode(binaryData);
            emailObj.encodingKey=  mrObj[0].encoding; //'ISO-8859-1';
            emailObj.type_x= mrObj[0].type; //'text';
            emailObj.style= mrObj[0].style; //'none';
        
            List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { emailObj });
            saveResult = results[0];

        } else if(mrObj[0].metadataType == 'outboundMessage'){      
            
            MetadataService.WorkflowOutboundMessage outBoundM = new MetadataService.WorkflowOutboundMessage();
            outBoundM.apiVersion=60.0;
            outBoundM.endpointUrl= mrObj[0].url; //'https://afterfinallyTested.com';
            outBoundM.fullName= mrObj[0].objectName + '.' + mrObj[0].uniqueName; //'Account.test';
            outBoundM.includeSessionId= mrObj[0].includeSessionId; //false;
            outBoundM.integrationUser= mrObj[0].integrationUser; //'akash.chauhan@testmetadataapi.com';
            outBoundM.name= mrObj[0].name; //'test';
            outBoundM.protected_x= mrObj[0].protected_x; //false;        
    
            List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { outBoundM });
            saveResult = results[0];
                
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
        return new List<String>{UserInfo.getSessionId()};
        
        
    }
}