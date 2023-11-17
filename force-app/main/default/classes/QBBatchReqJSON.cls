public class QBBatchReqJSON {
    public List<BatchItemRequest> BatchItemRequest;

    public QBBatchReqJSON() {
        BatchItemRequest = new List<BatchItemRequest>();
    }

    // public void addBatchItem(String bId, Boolean trackQtyOnHand, String name, Decimal qtyOnHand,Decimal UnitPrice, String incomeAccountName, String incomeAccountValue, String assetAccountName, String assetAccountValue, String invStartDate, String expenseAccountName, String expenseAccountValue) {
    public void addBatchItem(String bId, Boolean trackQtyOnHand, String name, Decimal qtyOnHand,Decimal UnitPrice, String incomeAccountName, String incomeAccountValue,  String invStartDate) {
        BatchItemRequest.add(new BatchItemRequest(
            bId,
            new Item(
                trackQtyOnHand,
                name,
                qtyOnHand,
                UnitPrice,
                new IncomeAccountRef(incomeAccountName, incomeAccountValue),
                invStartDate,
                'Service'
            ),
            'create'
        ));
    }

    public class BatchItemRequest {
        public String bId;
        public Item Item;
        public String operation;

        public BatchItemRequest(String bId, Item Item, String operation) {
            this.bId = bId;
            this.Item = Item;
            this.operation = operation;
        }
    }

    public class Item {
        public Boolean TrackQtyOnHand;
        public String Name;
        public Decimal QtyOnHand;
        public Decimal UnitPrice;
        public IncomeAccountRef IncomeAccountRef;
        public AssetAccountRef AssetAccountRef;
        public String InvStartDate;
        public String Type;
        public ExpenseAccountRef ExpenseAccountRef;

        public Item(Boolean TrackQtyOnHand, String Name, Decimal QtyOnHand,Decimal UnitPrice, IncomeAccountRef IncomeAccountRef, String InvStartDate, String Type) {
            this.TrackQtyOnHand = TrackQtyOnHand;
            this.Name = Name;
            this.QtyOnHand = QtyOnHand;
            this.UnitPrice = UnitPrice;
            this.IncomeAccountRef = IncomeAccountRef;
            this.InvStartDate = InvStartDate;
            this.Type = Type;
        }
    }

    public class IncomeAccountRef {
        public String name;
        public String value;

        public IncomeAccountRef(String name, String value) {
            this.name = name;
            this.value = value;
        }
    }

    public class AssetAccountRef {
        public String name;
        public String value;

        public AssetAccountRef(String name, String value) {
            this.name = name;
            this.value = value;
        }
    }

    public class ExpenseAccountRef {
        public String name;
        public String value;

        public ExpenseAccountRef(String name, String value) {
            this.name = name;
            this.value = value;
        }
    }
}