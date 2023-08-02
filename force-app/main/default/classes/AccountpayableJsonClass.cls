public class AccountpayableJsonClass{
    
    public cls_AccountPayable[] AccountPayable;
	public class cls_AccountPayable {
		public String ExternalPayableNumber;
		public String Id;	//123
		public String Contact;	//0014100000Wv7XOAAZ
		public String CostCode;	//0014100000Wv7XOAAZ
		public String DateRecived;	//2020 - 12 - 29
		public String Description;	//test
		public Integer Discount;	//10
		public String DueDate;	//2020 - 12 - 29
		public String Employee;	//0014100000Wv7XOAAZ
		public String IssueDate;	//2020 - 12 - 29
		public String LiabilityGLAccount;	//0014100000Wv7XOAAZ
		public boolean Posted;
		public String Project;	//a1Q1K000004OIswUAG
		public String PurchaseOrder;	//a1Q1K000004OIswUAG
		public String RefNo;	//text
		public String Status;	//Partially Paid
		public Integer Tax;	//10
		public String Terms;	//Due on Receipt
		public String Vendor;	//0014100000Wv7XOAAZ
		public cls_AccountPayableItem[] AccountPayableItem;
	}
public class cls_AccountPayableItem {
		public String AccountPayable;	//a0q1K00000FysYVQAZ
		public String Id;	//a0r1K00000LzQcnQAF
		public String BudgetLine;	//a0r1K00000LzQcnQAF
		public String CostCode;	//0014100000Wv7XOAAZ
		public String Description;	//longtextare
		public String ExpenseGLAccount;	//0014100000Wv7XOAAZ
		public String ItemTitle;	//testdata
		public String LiabilityGLAccount;	//0014100000Wv7XOAAZ
		public String Name;	//All-In Costs
		public String Product;	//a1Q1K000004OIswUAG
		public String PurchaseOrderItem;	//a1Q1K000004OIswUAG
		public Integer Quantity;	//2
		public Integer Tax;	//10
		public Double UnitPrice;	//226.99
	}
	
	public static AccountpayableJsonClass parse(String json){
		return (AccountpayableJsonClass) System.JSON.deserialize(json, AccountpayableJsonClass.class);
	}

	/*static testMethod void testParse() {
		String json=		'{'+
		'	"AccountPayable": [{'+
		'		"Recordnumber": "1",'+
		'		"Id": "123",'+
		'		"Contact": "0014100000Wv7XOAAZ",'+
		'		"CostCode":"0014100000Wv7XOAAZ",'+
		'		"DateRecived": "2020 - 12 - 29",'+
		'		"Description":"test",'+
		'		"Discount": 10.00,'+
		'		"DueDate": "2020 - 12 - 29",'+
		'		"Employee":"0014100000Wv7XOAAZ",'+
		'		"ExternalPayableNumber":"tesxt",'+
		'		"IssueDate":"2020 - 12 - 29",'+
		'		"LiabilityGLAccount":"0014100000Wv7XOAAZ",'+
		'		"Posted":false,'+
		'		"Project": "a1Q1K000004OIswUAG",'+
		'		"PurchaseOrder": "a1Q1K000004OIswUAG",'+
		'		"RefNo":"text",'+
		'		"Status": "Partially Paid",'+
		'		"Tax": 10.00,'+
		'		"Terms":"Due on Receipt",'+
		'		"Vendor": "0014100000Wv7XOAAZ",'+
		'		"AccountPayableItem": [{'+
		''+
		'				"AccountPayable": "a0q1K00000FysYVQAZ",'+
		'				"Id": "a0r1K00000LzQcnQAF",'+
		'				"BudgetLine":"a0r1K00000LzQcnQAF",'+
		'				"CostCode":"0014100000Wv7XOAAZ",'+
		'				"Description":"longtextare",'+
		'				"ExpenseGLAccount":"0014100000Wv7XOAAZ",'+
		'				"ItemTitle":"testdata",'+
		'				"LiabilityGLAccount":"0014100000Wv7XOAAZ",'+
		'				"Name": "All-In Costs",'+
		'				"Product": "a1Q1K000004OIswUAG",'+
		'				"PurchaseOrderItem":"a1Q1K000004OIswUAG",'+
		'				"Quantity": 2,'+
		'				"Tax": 10.00,'+
		'				"UnitPrice":226.99'+
		''+
		'				},'+
		'			{'+
		''+
		'				"AccountPayable": "a0q1K00000FysYVQAZ",'+
		'				"Id": "a0r1K00000LzQcnQAF",'+
		'				"BudgetLine":"a0r1K00000LzQcnQAF",'+
		'				"CostCode":"0014100000Wv7XOAAZ",'+
		'				"Description":"longtextare",'+
		'				"ExpenseGLAccount":"0014100000Wv7XOAAZ",'+
		'				"ItemTitle":"testdata",'+
		'				"LiabilityGLAccount":"0014100000Wv7XOAAZ",'+
		'				"Name": "All-In Costs",'+
		'				"Product": "a1Q1K000004OIswUAG",'+
		'				"PurchaseOrderItem":"a1Q1K000004OIswUAG",'+
		'				"Quantity": 2,'+
		'				"Tax": 10.00,'+
		'				"UnitPrice":226.99'+
		''+
		''+
		'			},'+
		'			{'+
		''+
		'				"AccountPayable": "a0q1K00000FysYVQAZ",'+
		'				"Id": "a0r1K00000LzQcnQAF",'+
		'				"BudgetLine":"a0r1K00000LzQcnQAF",'+
		'				"CostCode":"0014100000Wv7XOAAZ",'+
		'				"Description":"longtextare",'+
		'				"ExpenseGLAccount":"0014100000Wv7XOAAZ",'+
		'				"ItemTitle":"testdata",'+
		'				"LiabilityGLAccount":"0014100000Wv7XOAAZ",'+
		'				"Name": "All-In Costs",'+
		'				"Product": "a1Q1K000004OIswUAG",'+
		'				"PurchaseOrderItem":"a1Q1K000004OIswUAG",'+
		'				"Quantity": 2,'+
		'				"Tax": 10.00,'+
		'				"UnitPrice":226.99'+
		''+
		'			}'+
		''+
		'		]'+
		'	}]'+
		'}';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}*/
}