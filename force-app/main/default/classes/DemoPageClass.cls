public without sharing class DemoPageClass {

    public static void sendemailfromapex() {
        //send email using single email message
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress Limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'jaimin.s@mvclouds.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Test Email from Apex');
        mail.setPlainTextBody('Hello World!');
        if ( owea.size() > 0 ) {
mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('Email sent successfully');
    }
    

}