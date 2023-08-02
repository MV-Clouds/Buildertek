@IsTest(SeeAllData=true)
public with sharing class InSiteHostControllerTest {

    @IsTest(SeeAllData=true)
    public static void testControllerMethod() {
        InSiteHostController ctrlr = new InSiteHostController();
        String url = ctrlr.getIframeUrl();
        System.assertNotEquals(null, url, 'URL should not be null');
    }
}