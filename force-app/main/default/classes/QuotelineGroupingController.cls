/*
 Developed By: Laxman B
 Date:  24-June-2020.

 */
global without sharing class QuotelineGroupingController{
    // global string relatedToId {get;set;}
    global string quoteid;

    global string RollupAllGroupName{ get; set; }

    global list<buildertek__Quote_Item__c> QuoteItem;
    global list<buildertek__Quote_Line_Group__c> Quotelinegroup;
    global list<buildertek__Cost_Codes__c> QuotelineCostCode;
    global map<id, list<buildertek__Quote_Item__c>> quotegroupingmap;
    global map<id, list<buildertek__Quote_Item__c>> quoteCostCodemap;

    global decimal Totalquotelineamount{ get; set; }

    global list<wrapperClass> wrapperlst{ get; set; }

    global list<buildertek__Quote__c> quotesList{ get; set; }

    global QuotelineGroupingController(){
    }

    global void setrelatedToId(string Id){
        this.quoteid = Id;
        Quotelinegroupingdata();
    }

    global string getrelatedToId(){
        return quoteid;
    }

    global void Quotelinegroupingdata(){
        wrapperlst = new list<wrapperClass>();
        Totalquotelineamount = 0.0;
        quotesList = [select id, buildertek__Project__c, buildertek__Roll_Up__c, buildertek__Rollup_by_Group__c, buildertek__Roll_Up_All_Lines_by_Cost_Code__c, buildertek__Subtotal__c, Total__c, Tax__c, Grand_Total__c, buildertek__Discount__c
                      from buildertek__Quote__c
                      where id = :quoteid
                      limit 1];

        QuoteItem = [select Id, Name, buildertek__Product__c, buildertek__Quote__c, buildertek__Quote__r.name, buildertek__Grouping__c, buildertek__Cost_Code__c, buildertek__Grouping__r.Name, buildertek__Unit_Cost__c, buildertek__Unit_Price__c, buildertek__Net_Unit__c, buildertek__Total_Cost__c, buildertek__List_Total__c, buildertek__Net_Total_Price__c, buildertek__Gross_Profit__c, buildertek__Quantity__c, buildertek__Status__c, buildertek__Discount__c
                     from buildertek__Quote_Item__c
                     where buildertek__Quote__c = :quoteid AND buildertek__Status__c = :'Accept' AND buildertek__Not_Customer_Visible__c = false];
        if (quotesList[0].buildertek__Rollup_by_Group__c == true && quotesList[0].buildertek__Roll_Up__c != true){
            system.debug('QuoteItem---->' + QuoteItem.size());
            set<Id> groupid = new set<Id>();
            quotegroupingmap = new map<id, list<buildertek__Quote_Item__c>>();
            for (buildertek__Quote_Item__c qutitem : QuoteItem){
                if (!quotegroupingmap.containsKey(qutitem.buildertek__Grouping__c)){
                    quotegroupingmap.put(qutitem.buildertek__Grouping__c, new list<buildertek__Quote_Item__c>());
                }
                quotegroupingmap.get(qutitem.buildertek__Grouping__c).add(qutitem);

                if (qutitem.buildertek__Grouping__c != null){
                    groupid.add(qutitem.buildertek__Grouping__c);
                }
            }

            Quotelinegroup = [Select Id, Name
                              from buildertek__Quote_Line_Group__c
                              where Id = :groupId];
            system.debug('Quotelinegroupsize---->' + Quotelinegroup.size());

            for (buildertek__Quote_Line_Group__c quotelinegrouprec : Quotelinegroup){
                decimal quoteitemNetunitprice = 0.0;
                decimal quoteitemlistTotal = 0.0;
                wrapperClass wrap = new wrapperClass();
                wrap.groupName = quotelinegrouprec.Name;
                for (buildertek__Quote_Item__c quoteitemrec : quotegroupingmap.get(quotelinegrouprec.Id)){
                    if (quoteitemrec.buildertek__Net_Unit__c != null){
                        quoteitemNetunitprice += quoteitemrec.buildertek__Net_Unit__c;
                    }
                    if (quoteitemrec.buildertek__Net_Total_Price__c != null){
                        quoteitemlistTotal += quoteitemrec.buildertek__Net_Total_Price__c;
                    }
                }
                wrap.netunitprice = quoteitemNetunitprice;
                wrap.listTotal = quoteitemlistTotal;
                wrapperlst.add(wrap);
            }

            if (quotegroupingmap.containsKey(null) &&  quotegroupingmap.get(null).size() > 0) {
                wrapperClass wrap = new wrapperClass();
                wrap.groupName = 'Grouping None';
                decimal quoteitemNetunitprice = 0.0;
                decimal quoteitemlistTotal = 0.0;
                for (buildertek__Quote_Item__c quoteLineWithNullCostCode : quotegroupingmap.get(null)) {
                    if (quoteLineWithNullCostCode != null) {
                        if (quoteLineWithNullCostCode.buildertek__Net_Unit__c != null){
                            quoteitemNetunitprice += quoteLineWithNullCostCode.buildertek__Net_Unit__c;
                        }
                        if (quoteLineWithNullCostCode.buildertek__Net_Total_Price__c != null){
                            quoteitemlistTotal += quoteLineWithNullCostCode.buildertek__Net_Total_Price__c;
                        }
                    }
                }
                wrap.netunitprice = quoteitemNetunitprice;
                wrap.listTotal = quoteitemlistTotal;
                wrapperlst.add(wrap);
            }

            system.debug(wrapperlst.size() + 'wrapperlst----->' + wrapperlst);
        }
        if (((quotesList[0].buildertek__Roll_Up__c == true && quotesList[0].buildertek__Rollup_by_Group__c == true) || quotesList[0].buildertek__Roll_Up__c == true)){
            wrapperClass wrap = new wrapperClass();
            for (buildertek__Quote_Item__c qutitem : QuoteItem){

                Totalquotelineamount += qutitem.buildertek__Net_Total_Price__c;

            }
            wrap.groupName = 'All Work and Material';
            wrap.listTotal = Totalquotelineamount;
            wrapperlst.add(wrap);

        }

        if (quotesList[0].buildertek__Roll_Up_All_Lines_by_Cost_Code__c == true){
            system.debug('QuoteItem---->' + QuoteItem.size());
            set<Id> costCodeId = new set<Id>();
            quoteCostCodemap = new map<id, list<buildertek__Quote_Item__c>>();
            for (buildertek__Quote_Item__c qutitem : QuoteItem){
                if (!quoteCostCodemap.containsKey(qutitem.buildertek__Cost_Code__c)){
                    quoteCostCodemap.put(qutitem.buildertek__Cost_Code__c, new list<buildertek__Quote_Item__c>());
                }
                quoteCostCodemap.get(qutitem.buildertek__Cost_Code__c).add(qutitem);

                if (qutitem.buildertek__Cost_Code__c != null){
                    costCodeId.add(qutitem.buildertek__Cost_Code__c);
                }
            }

            QuotelineCostCode = [Select Id, Name, buildertek__Major_Description__c
                              from buildertek__Cost_Codes__c
                              where Id = :costCodeId];
            system.debug('QuotelineCostCodesize---->' + QuotelineCostCode.size());

            for (buildertek__Cost_Codes__c quotelinegrouprec : QuotelineCostCode){
                decimal quoteitemNetunitprice = 0.0;
                decimal quoteitemlistTotal = 0.0;
                wrapperClass wrap = new wrapperClass();
                wrap.groupName = quotelinegrouprec.Name;
                wrap.groupMajorDescription = quotelinegrouprec.buildertek__Major_Description__c;
                for (buildertek__Quote_Item__c quoteitemrec : quoteCostCodemap.get(quotelinegrouprec.Id)){
                    if (quoteitemrec.buildertek__Net_Unit__c != null){
                        quoteitemNetunitprice += quoteitemrec.buildertek__Net_Unit__c;
                    }
                    if (quoteitemrec.buildertek__Net_Total_Price__c != null){
                        quoteitemlistTotal += quoteitemrec.buildertek__Net_Total_Price__c;
                    }
                }
                wrap.netunitprice = quoteitemNetunitprice;
                wrap.listTotal = quoteitemlistTotal;
                wrapperlst.add(wrap);
            }

            if (quoteCostCodemap.containsKey(null) &&  quoteCostCodemap.get(null).size() > 0) {
                wrapperClass wrap = new wrapperClass();
                wrap.groupName = 'No Cost Code';
                decimal quoteitemNetunitprice = 0.0;
                decimal quoteitemlistTotal = 0.0;
                for (buildertek__Quote_Item__c quoteLineWithNullCostCode : quoteCostCodemap.get(null)) {
                    if (quoteLineWithNullCostCode != null) {
                        if (quoteLineWithNullCostCode.buildertek__Net_Unit__c != null){
                            quoteitemNetunitprice += quoteLineWithNullCostCode.buildertek__Net_Unit__c;
                        }
                        if (quoteLineWithNullCostCode.buildertek__Net_Total_Price__c != null){
                            quoteitemlistTotal += quoteLineWithNullCostCode.buildertek__Net_Total_Price__c;
                        }
                    }
                }
                wrap.netunitprice = quoteitemNetunitprice;
                wrap.listTotal = quoteitemlistTotal;
                wrapperlst.add(wrap);
            }
            system.debug(wrapperlst.size() + 'wrapperlst----->' + wrapperlst);
        }
    }

    global class wrapperClass{
        global String groupName{ get; set; }

        global decimal netunitprice{ get; set; }

        global decimal listTotal{ get; set; }

        global String groupMajorDescription{ get; set; }
    }

}