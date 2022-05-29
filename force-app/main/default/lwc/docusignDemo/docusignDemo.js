import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getUrl from "@salesforce/apex/DocuSignDemoController.getUrl";

export default class DocusignDemo extends NavigationMixin(LightningElement) {
    _url;
    _error;

    @wire(getUrl)
    wireGetUrl(data, error) {
        if (error) {
            this._error = error;
        } else if (data) {
            console.log(data?.data);
            this._url = data?.data;
        }
    }

    handleClick() {
        this[NavigationMixin.GenerateUrl]({
            type: "standard__webPage",
            attributes: {
                url: this._url
            }
        }).then((generatedUrl) => {
            console.log("generatedUrl");
            console.log(generatedUrl);
            window.open(generatedUrl);
        });
    }
}

//{!URLFOR(IF($Site.prefix == '/s','/apex/dfsle__sending', $Site.Prefix +'/apex/dfsle__sending'), null, [sId = Contract.ParentContractId__c, quickSend = false, isEmbedded = false, templateId = 'a0B0k00000D5F2UEAV', recordId = Contract.ParentContractId__c, title = 'Send for Signing'])}