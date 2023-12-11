public class QBBatchResJSON {
    public List<BatchItemResponse> BatchItemResponse;
    // public String time;

    public QBBatchResJSON() {
        BatchItemResponse = new List<BatchItemResponse>();
    }

    public class BatchItemResponse {
        public Item Item;
        public String bId;

        public BatchItemResponse(Item Item, String bId) {
            this.Item = Item;
            this.bId = bId;
        }
    }

    public class Item {
        public String Name;
        public Boolean Active;
        public String FullyQualifiedName;
        public Boolean Taxable;
        public Decimal UnitPrice;
        public String Type;
        public IncomeAccountRef IncomeAccountRef;
        public Decimal PurchaseCost;
        public ExpenseAccountRef ExpenseAccountRef;
        public AssetAccountRef AssetAccountRef;
        public Boolean TrackQtyOnHand;
        public Integer QtyOnHand;
        public String InvStartDate;
        public Boolean DeferredRevenue;
        public String domain;
        public Boolean sparse;
        public String Id;
        public String SyncToken;
        public MetaData MetaData;
    }

    public class IncomeAccountRef {
        public String value;
        public String name;
    }

    public class ExpenseAccountRef {
        public String value;
        public String name;
    }

    public class AssetAccountRef {
        public String value;
        public String name;
    }

    public class MetaData {
        public String CreateTime;
        public String LastUpdatedTime;
    }

    public static QBBatchResJSON parse(String json) {
        return (QBBatchResJSON) System.JSON.deserialize(json, QBBatchResJSON.class);
    }
}