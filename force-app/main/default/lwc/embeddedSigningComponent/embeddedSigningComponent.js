import { LightningElement, api } from "lwc";
import sendEnvelope from "@salesforce/apex/EmbeddedSigningController.sendEnvelope";
import getEmbeddedSigningUrl from "@salesforce/apex/EmbeddedSigningController.getEmbeddedSigningUrl";

export default class EmbeddedSigningComponent extends LightningElement {
  template = "32ab0c1e-f51e-47bd-a3ce-ab66c33b38be";
  description = "Embedded Signing";
  @api recordId;
  handleClick() {
    sendEnvelope({
      template: this.template,
      description: this.description,
      recordId: this.recordId
    })
      .then((envelopeId) =>
        getEmbeddedSigningUrl({
          envId: envelopeId,
          url: window.location.href
        })
      )
      .then((signingUrl) => {
        window.location.href = signingUrl;
      })
      .catch((error) => {
        console.log("Error:");
        console.log(error);
      });
  }
}