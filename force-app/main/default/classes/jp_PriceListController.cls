public without sharing class jp_PriceListController {

    private String status = pba.Settings.getSettingValue('price_list_status');
    private String relationFieldSetting = pba.Settings.getSettingValue('price_list_master_property_relation_field');
    private String relationFieldURL = ApexPages.currentPage().getParameters().get('relation');
    private String projectID = ApexPages.currentPage().getParameters().get('ID');
    private String propertytype = ApexPages.currentPage().getParameters().get('type');
    private String orderby = ApexPages.currentPage().getParameters().get('orderby');
    private List<pba__Listing__c> projectListings;

    public jp_PriceListController(ApexPages.StandardController controller) {
        System.debug('propertytype-->'+propertytype);
        if (projectID == null) {
            return ;
        } 
        string sql = 'SELECT ' + allListingsFields() + ' FROM pba__Listing__c WHERE pba__Status__c IN (\'' + getStatus() + '\')';
        
        sql += ' AND ' + getRelationField() + ' = \'' + projectID + '\'';
        
        if(propertytype  != null ){
         sql += ' AND pba__PropertyType__c = \'' + propertytype + '\'';
         
        }

        sql += ' AND pba__PropertyType__c != \'House\'  ';



        if (orderby != null) {
            sql += ' ORDER BY ' + orderby;
        }
        System.debug(sql.split('FROM').get(1));
        System.debug('sql-->'+sql);
        projectListings = Database.query(sql);
    }

    private String allListingsFields() {
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('pba__Listing__c').getDescribe().fields.getMap();
        String fields = '';
        for(String s: fieldMap.keySet()) {
            fields += s + ',';
        }

        return fields.left(fields.length()-1);
    }

    private String getStatus() {
        return SQLEncode(status == null ? 'Available;Active' : status);
    }

    private String getRelationField() {
        if (relationFieldURL != null) {
            return relationFieldURL;
        } else {
            return relationFieldSetting == null ? 'Project_Unit__c' : relationFieldSetting;
        }
    }

    public List<pba__Listing__c> GetProjectListings() {
        return projectListings;
    }

    public static string SQLEncode(string text) {
        return text.replace(';', '\',\'');
    }
}