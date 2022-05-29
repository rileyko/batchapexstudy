@isTest
public class ContentDocumentControllerTest {
    @TestSetup
    static void setup() {
        Account acct = new Account(Name = 'TestAccount');
        insert acct;

        Contact ct1 = new Contact(
            LastName = 'ct1_LastName',
            AccountId = acct.Id,
            Email = 'ct1@test.com',
            Title = 'CEO',
            Department = 'ct1_Department'
        );
        Contact ct2 = new Contact(
            LastName = 'ct2_LastName',
            AccountId = acct.Id,
            Email = 'ct2@test.com',
            Title = 'CFO',
            Department = 'ct2_Department'
        );
        insert ct1;
        insert ct2;

        dfsle__EnvelopeStatus__c envelopeStatus = new dfsle__EnvelopeStatus__c(
            dfsle__EmailSubject__c = 'Test Email Subject',
            dfsle__DocuSignId__c = '03404b23-4397-442d-8bf9-34a6d3bdd853'
        );
        insert envelopeStatus;

        dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c(
            dfsle__EnvelopeStatus__c = envelopeStatus.Id,
            Contact__c = ct2.Id,
            dfsle__Email__c = ct2.Email,
            Name = ct2.LastName
        );
        insert recipientStatus;

        System.debug('DocusignId: ' + envelopeStatus.dfsle__DocuSignId__c);
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Envelope_' + envelopeStatus.dfsle__DocuSignId__c + '.pdf',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;

        List<Contentdocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];

        ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = ct1.Id,
            ContentDocumentId = documents[0].Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;
    }

    @isTest
    private static void fixLinkTest() {
        Test.startTest();

        Contact ct2 = [SELECT Id FROM Contact WHERE Title = 'CFO'];
        List<ContentDocument> documents = [SELECT Id, Title FROM ContentDocument WHERE Title LIKE 'Envelope%'];

        ContentDocumentController.fixLink(documents);

        List<ContentDocumentLink> link = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :documents[0].Id];

        System.assertEquals(ct2.Id, link[0].LinkedEntityId);

        Test.stopTest();
    }
}