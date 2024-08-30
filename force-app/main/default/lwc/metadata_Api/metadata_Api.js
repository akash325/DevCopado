import { LightningElement } from 'lwc';
import updateData from '@salesforce/apex/Metadata_Api.updateData';
import updateUsingCSV from '@salesforce/apex/ToolingAPIUtility.updateSiteSettingsByCSV';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Metadata_Api extends LightningElement {

    value = '';
    customLabel = false;
    customMetadata = false;
    remoteSiteSetting = false;
    emailTemplate = false;
    showEmailStyle = false;
    outboundMessage = false;
    showLabel = false;
    showSpinner = false;
    useStaticResource = false;
    staticResourceName;

    metadataRecord = {
        transactionType : '',
        metadataType : '',
        fullName : '',
        shortDescription : '',
        value : '',
        protected_x : false,
        mdtName : '',
        mdtRecName : '',
        label : '',
        fieldName : '',
        url : '',
        disableProtocolSecurity : false,
        isActive : false,
        name : '',
        folderName : '',
        uniqueName : '',
        encoding : '',
        type : '',
        style : 'none',
        content : '',
        available : false,
        objectName : '',
        integrationUser : 'akash.chauhan@testmetadataapi.com',
        includeSessionId : false,

    };

    get options() {
        return [
            { label: 'Custom Label', value: 'customLabel' },
            { label: 'Custom Metadata', value: 'customMetadata' },
            { label: 'Remote Site Setting', value: 'remoteSiteSetting' },
            { label: 'Email Template', value: 'emailTemplate' },
            { label: 'Outbound Message', value: 'outboundMessage' }
        ];
    }

    get encodingOptions() {
        return [
            { label: 'Unicode (UTF-8)', value: 'UTF-8' },
            { label: 'General US & Western Europe (ISO-8859-1, ISO-LATIN-1)', value: 'ISO-8859-1' },
            { label: 'Japanese (Shift-JIS)', value: 'Shift_JIS' },
            { label: 'Japanese (JIS)', value: 'ISO-2022-JP' },
            { label: 'Japanese (EUC-JP)', value: 'EUC-JP' },
            { label: 'Japanese (Shift-JIS_2004)', value: 'x-SJIS_0213' },
            { label: 'Korean (ks_c_5601-1987)', value: 'ks_c_5601-1987' },
            { label: 'Traditional Chinese (Big5)e', value: 'Big5' },
            { label: 'Simplified Chinese (GB2312)e', value: 'GB2312' },
            { label: 'Traditional Chinese Hong Kong (Big5–HKSCS)', value: 'Big5-HKSCS' }
        ];
    }

    get emailTypeOptions() {
        return [
            { label: 'text', value: 'text' },
            { label: 'html', value: 'html' },
            { label: 'custom', value: 'custom' },
            { label: 'visualforce ', value: 'visualforce' }
        ];
    }

    get emailStyleOptions() {
        return [
            { label: 'none', value: 'none' },
            { label: 'freeForm', value: 'freeForm' },
            { label: 'formalLetter', value: 'formalLetter' },
            { label: 'promotionRight', value: 'promotionRight' },
            { label: 'promotionLeft', value: 'promotionLeft' },
            { label: 'newsletter', value: 'newsletter' },
            { label: 'products', value: 'products' },
        ];
    }

    handleChange(event) {
        console.log('in handleChange');
        this.showLabel = true;
        this.value = event.detail.value;
        this.metadataRecord.metadataType = event.target.value;
        console.log('event.target.name - ' + event.target.name);
        console.log('event.target.value - ' + event.target.value);
        if(this.value == 'customLabel'){
            this.customLabel = true;
            this.customMetadata = false;
            this.remoteSiteSetting = false;
            this.emailTemplate = false;
            this.outboundMessage = false;

        } else if(this.value == 'customMetadata'){
            this.customLabel = false;
            this.customMetadata = true;
            this.remoteSiteSetting = false;
            this.emailTemplate = false;
            this.outboundMessage = false;
        } else if(this.value == 'remoteSiteSetting'){
            this.customLabel = false;
            this.customMetadata = false;
            this.remoteSiteSetting = true;
            this.emailTemplate = false;
            this.outboundMessage = false;
        } else if(this.value == 'emailTemplate'){
            this.customLabel = false;
            this.customMetadata = false;
            this.remoteSiteSetting = false;
            this.emailTemplate = true;
            this.outboundMessage = false;
        } else {
            this.customLabel = false;
            this.customMetadata = false;
            this.remoteSiteSetting = false;
            this.emailTemplate = false;
            this.outboundMessage = true;
        }
        
    }

    handleFieldChange(event){
        console.log('in handleFieldChange');
        console.log('event.target.name - ' + event.target.name);
        console.log('event.target.value - ' + event.target.value);

        if(event.target.name == 'fullName'){
            this.metadataRecord.fullName = event.target.value;
        } else if(event.target.name == 'shortDescription'){
            this.metadataRecord.shortDescription = event.target.value;
        } else if(event.target.name == 'value'){
            this.metadataRecord.value = event.target.value;
        } else if(event.target.name == 'protected_x'){
            this.metadataRecord.protected_x = event.target.checked;
        } else if(event.target.name == 'mdtName'){
            this.metadataRecord.mdtName = event.target.value;
        } else if(event.target.name == 'mdtRecName'){
            this.metadataRecord.mdtRecName = event.target.value;
        } else if(event.target.name == 'label'){
            this.metadataRecord.label = event.target.value;
        } else if(event.target.name == 'fieldName'){
            this.metadataRecord.fieldName = event.target.value;
        } else if(event.target.name == 'url'){
            this.metadataRecord.url = event.target.value;
        } else if(event.target.name == 'disableProtocolSecurity'){
            this.metadataRecord.disableProtocolSecurity = event.target.checked;
        } else if(event.target.name == 'isActive'){
            this.metadataRecord.isActive = event.target.checked;
        } else if(event.target.name == 'name'){
            this.metadataRecord.name = event.target.value;
        } else if(event.target.name == 'folderName'){
            this.metadataRecord.folderName = event.target.value;
        } else if(event.target.name == 'uniqueName'){
            this.metadataRecord.uniqueName = event.target.value;
        } else if(event.target.name == 'encoding'){
            this.metadataRecord.encoding = event.target.value;
        } else if(event.target.name == 'type'){
            this.metadataRecord.type = event.target.value;
            if(event.target.value == 'html'){
                this.showEmailStyle = true;
            } else {
                this.showEmailStyle = false;
            }
            
        } else if(event.target.name == 'style'){
            this.metadataRecord.style = event.target.value;
        } else if(event.target.name == 'content'){
            this.metadataRecord.content = event.target.value;
        } else if(event.target.name == 'available'){
            this.metadataRecord.available = event.target.checked;
        } else if(event.target.name == 'objectName'){
            this.metadataRecord.objectName = event.target.value;
        } else if(event.target.name == 'integrationUser'){
            this.metadataRecord.integrationUser = event.target.value;
        } else if(event.target.name == 'includeSessionId'){
            this.metadataRecord.includeSessionId = event.target.checked;
        } else if(event.target.name == 'staticResource'){
            this.staticResourceName = event.target.value;
        }
        
        console.log('this.metadataRecord - ' + JSON.stringify(this.metadataRecord));
    }
    
    
    handleUpdate(event){
        console.log('in handleUpdate');
        console.log('event.target.name - ' + event.target.name);
        this.metadataRecord.transactionType = event.target.name;
        this.showSpinner = true;
        updateData({mdtData : JSON.stringify(this.metadataRecord)})
        .then(result =>{
            this.showSpinner = false;

            if(result.IsSuccess){
                if(this.metadataRecord.transactionType == 'create'){
                    this.showToast('Record Created Successfully', 'success');
                } else {
                    this.showToast('Record Updated Successfully', 'success');
                }
                
            }
            if(!result.IsSuccess){
                this.showToast(result.Error[1], 'error');
            }
            console.log('result - ' + result);
            console.log('result - ' + JSON.stringify(result));
        })
        .catch(error=>{
            console.log('error - ' + JSON.stringify(error));
            this.showToast(JSON.stringify(error), 'error');
            this.showSpinner = false;
        })
    }

    showToast(message, variant) {
        const event = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleToggle(event){

        console.log('event.target.checked - ' + event.target.checked);
        console.log('event.target.value - ' + event.target.value);
        if(event.target.checked){
            this.useStaticResource = true;
        } else {
            this.useStaticResource = false;
        }
    }
    
    updateDataUsingCSV(event){
        console.log('this.staticResourceName - ' + this.staticResourceName);
        console.log('in updateDataUsingCSV');
        this.showSpinner = true;
        updateUsingCSV({fileName :  this.staticResourceName})
        .then(result =>{
            this.showSpinner = false;

            if(result){
                this.showToast('Record Updated Successfully', 'success');
            }
        
            console.log('result - ' + result);
        })
        .catch(error=>{
            console.log('error - ' + JSON.stringify(error));
            this.showToast(JSON.stringify(error), 'error');
            this.showSpinner = false;
        })
    }
}