public class QBInvoiceLineJSON {

    public class MetaData{
        public String CreateTime;
        public String LastUpdatedTime;
    }

    public class ExpenseAccountRef{
        public String value;
		public String name; 
    }

    public class IncomeAccountRef{
        public String value;
		public String name;
    }

    public class AssetAccountRef{
        public String value;
		public String name;
    }

    public class Item{
        public String Id;
        public String domain;
		public Boolean sparse;
        public String SyncToken;
        public MetaData MetaData;
        public String Name;
        public String Description;
        public String PurchaseDesc;
        public Double PurchaseCost;
        public Boolean Active;
        public String FullyQualifiedName;
        public ExpenseAccountRef ExpenseAccountRef;
        public AssetAccountRef AssetAccountRef;
        public Boolean TrackQtyOnHand;
        public Boolean Taxable;
        public String UnitPrice;
        public String Type;
        public IncomeAccountRef IncomeAccountRef;
        public Integer QtyOnHand;
        public String InvStartDate;
    }

    public static QBInvoiceLineJSON parse(String json) {
        return (QBInvoiceLineJSON) System.JSON.deserialize(json, QBInvoiceLineJSON.class);
    }

    public static QBInvoiceLineJSON.Item parseCustomer(String json) {
        return (QBInvoiceLineJSON.Item) System.JSON.deserialize(json, QBInvoiceLineJSON.Item.class);
}
}