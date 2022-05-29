/**
 * @description       :
 * @author            : Seongho Kang
 * @group             : gme-service-i2max
 * @last modified on  : 04-07-2022
 * @last modified by  : Seongho Kang
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   04-07-2022   Seongho Kang   Initial Version
 **/
public class DocuSignDemoController {
    @AuraEnabled(cacheable=true)
    public static String getUrl() {
        try {
            String baseUrl = Site.getBaseSecureUrl();
            System.debug(baseUrl);
            PageReference pg = new PageReference(
                Site.getBaseSecureUrl() +
                '/apex/dfsle__sending?sId=8000k0000023vyBAAQ&quickSend=false&isEmbeded=false&templateId=a0B0k00000D5F2UEAV&recordId=8000k0000023vyBAAQ&title=something'
            );
            System.debug(pg.getUrl());

            return pg.getUrl();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}