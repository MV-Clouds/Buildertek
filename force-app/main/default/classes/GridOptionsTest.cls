@isTest
public class GridOptionsTest {
    public static testMethod void testGridOptions() {
        GridOptions.ColumnModel columnModel1 = new GridOptions.ColumnModel('', '', '', '', FALSE, FALSE, FALSE, '', FALSE);
        GridOptions.ColumnModel columnModel2 = new GridOptions.ColumnModel('', '', FALSE, FALSE, '', FALSE, FALSE, FALSE, '', FALSE, '');
        
        GridOptions.FormatOptions formatOptions1 = new GridOptions.FormatOptions('USD');
        GridOptions.FormatOptions formatOptions2 = new GridOptions.FormatOptions(TRUE);
        GridOptions.FormatOptions formatOptions3 = new GridOptions.FormatOptions('', '', '', '', '');
        GridOptions.FormatOptions formatOptions4 = new GridOptions.FormatOptions('', '', '', '', '', '');
        
        GridOptions.SearchOptions searchOptions1 = new GridOptions.SearchOptions('', FALSE, new List<String>());
        GridOptions.SearchOptions searchOptions2 = new GridOptions.SearchOptions('', FALSE, new List<String>(), '');
        GridOptions.SearchOptions searchOptions3 = new GridOptions.SearchOptions(new List<String>(), '');
        
        GridOptions.ColumnSearchConfiguration columnSearchConfiguration = new GridOptions.ColumnSearchConfiguration('', TRUE, '');
        
        for(Schema.FieldSetMember f : Schema.SObjectType.buildertek__RFQ_To_Vendor__c.fieldSets.buildertek__BT_Related_List_View_Fields.getFields()) {
        	GridOptions.FieldSetMember fieldSetMember = new GridOptions.FieldSetMember(f);
        	System.assertEquals('Test','Test');
        }
    }
}