public class DocuSignTGen1 {
    public static String getAccessToken() {
        
        DocuSign_Authentication__c docusignCredentials = [SELECT  buildertek__Public_Key__c, buildertek__Private_Key__c, buildertek__Integration_Key__c, buildertek__User_Id__c FROM buildertek__DocuSign_Authentication__c];
        
        
        String keyContents = '';
        keyContents = docusignCredentials.buildertek__Public_Key__c;
        keyContents += ',';
        keyContents = docusignCredentials.buildertek__Private_Key__c;
        
        system.debug('publicKey---->'+docusignCredentials.buildertek__Public_Key__c);
        system.debug('publicKey---->'+docusignCredentials.buildertek__Private_Key__c);
        
        // Get a new token
        JWT jwt = new JWT('RS256');
        // jwt.cert = 'JWTCert'; 
        // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = docusignCredentials.buildertek__Integration_Key__c;
        jwt.sub = docusignCredentials.buildertek__User_Id__c;
        jwt.aud =  'account-d.docusign.com';
        jwt.exp = '4000';
        jwt.scope = 'signature impersonation';
        
        String access_token = JWTBearerFlowCls.getAccessToken('account-d.docusign.com', jwt);
        return access_token;    
    }
    
}