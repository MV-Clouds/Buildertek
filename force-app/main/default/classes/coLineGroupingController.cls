public without sharing class coLineGroupingController {
    public string coId;
    public list<wrapperClass> wrapperlst {get;set;}
    public String orgCurr {get;set;}
    public Boolean rollUpByGroup {get;set;}
    public buildertek__Change_Order__c coData {get;set;}

    public void setrelatedToId(string Id){
        this.coId = Id;
        coLinegroupingdata();
    }
    public string getrelatedToId( ){
        return coId;
    }
        
    public void coLinegroupingdata() {
        wrapperlst = new list<wrapperClass>();

        System.debug('coId ==> '+coId);

        coData = new buildertek__Change_Order__c();
        coData = [SELECT Id, Name, buildertek__Roll_Up_All_Lines_by_Group__c, buildertek__Roll_Up_All_Lines__c, buildertek__Total_Amount__c, buildertek__Tax_Rate__c, buildertek__Total_Amount_Tax__c FROM buildertek__Change_Order__c WHERE Id =: coId];
        
        rollUpByGroup = coData.buildertek__Roll_Up_All_Lines_by_Group__c;

        List<buildertek__Change_Order_Item__c> coLineList = [SELECT Id, Name,buildertek__Unit_Price__c, buildertek__Description__c, buildertek__Quantity__c, buildertek__Total__c,
                                                                buildertek__SubTotal__c, buildertek__Unit_Sales_Price__c, buildertek__Tax_Rate__c,
                                                                buildertek__Budget_Line_Group__c, buildertek__Budget_Line_Group__r.Name
                                                                FROM buildertek__Change_Order_Item__c  WHERE buildertek__Change_Order__c =: coId 
                                                                ORDER BY buildertek__Budget_Line_Group__c];


        System.debug('coLineList ==> '+coLineList);
        orgCurr = UserInfo.getDefaultCurrency();

        String groupId = coId;
        for (buildertek__Change_Order_Item__c coLine : coLineList) {
            System.debug('coLine ==> '+coLine);
            if (groupId != coLine.buildertek__Budget_Line_Group__c) {
                wrapperClass wrapper = new wrapperClass();

                buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
                budgetGroup.Id = coLine.buildertek__Budget_Line_Group__c;
                budgetGroup.Name = coLine.buildertek__Budget_Line_Group__r.Name;

                wrapper.budgetGroup = budgetGroup;
                wrapper.totalGroupCost = 0;

                wrapperlst.add(wrapper);
                groupId = coLine.buildertek__Budget_Line_Group__c;
            } 
        }

        for (wrapperClass wpList : wrapperlst) {
            List<coLineData> coLineListData = new List<coLineData>();
            for (buildertek__Change_Order_Item__c coLine : coLineList) {
                System.debug('coLine ==> '+coLine);
                if (wpList.budgetGroup.Id == coLine.buildertek__Budget_Line_Group__c) {
                    coLineData coData = new coLineData();
                    coData.coLine = coLine;
                    if (coLine.buildertek__Total__c != null) {
                        wpList.totalGroupCost += coLine.buildertek__Total__c;
                    }
                    coLineListData.add(coData);
                }
            }
            wpList.coLineDataList = coLineListData;   
        }

        System.debug('Wrapper List ==> ' + wrapperlst);

    }  

    public class wrapperClass{
        public List<coLineData> coLineDataList {get;set;}
        public buildertek__Budget_Line_Group__c budgetGroup {get;set;}
        public Decimal totalGroupCost {get;set;}
    }

    public class coLineData{
        public buildertek__Change_Order_Item__c coLine{get;set;}
    }

}