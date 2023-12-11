public class QBBatchReqJSON {
    public List<BatchItemRequest> BatchItemRequest;

    public QBBatchReqJSON() {
        BatchItemRequest = new List<BatchItemRequest>();
    }

    // public void addBatchItem(String bId, Boolean trackQtyOnHand, String name, Decimal qtyOnHand,Decimal UnitPrice, String incomeAccountName, String incomeAccountValue, String assetAccountName, String assetAccountValue, String invStartDate, String expenseAccountName, String expenseAccountValue) {
    public void addBatchItem(String bId, Boolean trackQtyOnHand, String name, Decimal qtyOnHand, Decimal UnitPrice, String incomeAccountName, String incomeAccountValue,  Date invStartDate, String Type,  Boolean taxable, String inventoryAssetAccountName, String inventoryAssetAccountValue, String expenseAccountName, String expenseAccountValue) {
        BatchItemRequest.add(new BatchItemRequest(
            bId,
            new Item(
                trackQtyOnHand,
                name,
                qtyOnHand,
                UnitPrice,
                // Amount,
                new IncomeAccountRef(incomeAccountName, incomeAccountValue),
                invStartDate,
                'Inventory',
                taxable,
                new AssetAccountRef(inventoryAssetAccountName, inventoryAssetAccountValue),
                new ExpenseAccountRef(expenseAccountName,expenseAccountValue)

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
        // public Decimal Amount;
        public IncomeAccountRef IncomeAccountRef;
        public AssetAccountRef AssetAccountRef;
        public Date InvStartDate;
        public String Type;
        public ExpenseAccountRef ExpenseAccountRef;
        public boolean Taxable;

        public Item(Boolean TrackQtyOnHand, String Name, Decimal QtyOnHand, Decimal UnitPrice, IncomeAccountRef IncomeAccountRef, Date InvStartDate, String Type, Boolean taxable, AssetAccountRef AssetAccountRef, ExpenseAccountRef ExpenseAccountRef) {
            this.TrackQtyOnHand = TrackQtyOnHand;
            this.Name = Name;
            this.QtyOnHand = QtyOnHand;
            this.UnitPrice = UnitPrice;
            // this.Amount = Amount;
            this.IncomeAccountRef = IncomeAccountRef;
            this.AssetAccountRef = AssetAccountRef;
            this.ExpenseAccountRef = ExpenseAccountRef;
            this.InvStartDate = InvStartDate;
            this.Type = Type;
            this.Taxable = taxable;
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