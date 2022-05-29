/**
 * @description       :
 * @author            : Seongho Kang
 * @group             : gme-service-i2max
 * @last modified on  : 03-31-2022
 * @last modified by  : Seongho Kang
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   03-31-2022   Seongho Kang   Initial Version
 **/
public class SampleBulkSend {
    @future(callout=true)
    public static void sendBulkMethod(Id myListId) {
        //Id myDocumentId = '0690k000000zGuWAAU'; //The id of a document stored in a Salesforce library

        dfsle.UUID myTemplateId = dfsle.UUID.parse('32ab0c1e-f51e-47bd-a3ce-ab66c33b38be');

        //dfsle.Document myDocument = dfsle.Document.fromTemplate(
        //    myTemplateId, // The templateId in dfsle.UUID format
        //    'myTemplate'
        //); // Name of the template

        //Id myFileId = [SELECT id FROM ContentVersion WHERE ContentDocumentId = :myDocumentId LIMIT 1].id; // Content version ID of document to send
        // Create the draft bulk envelope. This will have exactly one placeholder bulk recipient
        //dfsle.Envelope myEnvelope = dfsle.BulkSendService.getDraftEnvelope(
        //    dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id>{ myFileId }), // Documents to send
        //    null
        //);
        dfsle.Envelope myEnvelope = dfsle.BulkSendService.getDraftEnvelope(
            new List<dfsle.Document>{
                dfsle.Document.fromTemplate(
                    myTemplateId, // The templateId in dfsle.UUID format
                    'myTemplate'
                )
            }, // Documents to send
            null
        );

        // Send envelope with a placeholder bulk recipient
        dfsle.BulkList.Result myResult = dfsle.BulkSendService.sendEnvelope(myListId, myEnvelope);

        // Save bulkStatusId to query status later
        Id myStatusId = myResult.bulkStatusId;
        System.debug('BulkStatusId: ' + myStatusId);
    }
}