@isTest
public class lightningTreeGridOptionsTest {
    public static testMethod void testLightningTreeGridOptions() {
        lightningTreeGridOptions.columns column = new lightningTreeGridOptions.columns();
        column.fieldName = 'Test';
        column.initialWidth = 'Test';
        column.label = 'Test';
        column.type = 'Test';
        System.assertEquals('Test','Test');
    }
}