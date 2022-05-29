public without sharing class ContentDocumentController {
    public static void fixLink(List<ContentDocument> documents) {
        if (documents.size() != 1) {
            return;
        }

        String envelopeId = documents[0].Title.substring(9, 45);

        System.debug('Envelope Id: ' + envelopeId);
        System.debug('Document Id: ' + documents[0].Id);

        dfsle__RecipientStatus__c recipientStatus = [
            SELECT Id, Contact__c
            FROM dfsle__RecipientStatus__c
            WHERE dfsle__EnvelopeStatus__r.dfsle__DocuSignId__c = :envelopeId
            LIMIT 1
        ];

        List<ContentDocumentLink> links = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :documents[0].Id
        ];

        List<ContentDocumentLink> updateLink = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : links) {
            Schema.SObjectType entityType = cdl.LinkedEntityId.getSObjectType();
            if (entityType == Schema.Contact.getSObjectType()) {
                updateLink.add(cdl);
            }
        }

        //updateLink[0].LinkedEntityId = recipientStatus.Contact__c;
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = updateLink[0].ContentDocumentId,
            LinkedEntityId = recipientStatus.Contact__c
        );

        Database.delete(updateLink);
        Database.insert(link);
    }
}