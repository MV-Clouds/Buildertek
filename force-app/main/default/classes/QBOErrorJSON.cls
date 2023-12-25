public class QBOErrorJSON {
			// public String time;
			public Fault Fault;
		public class Fault{
			public list<Error> Error;
			public String type;
		}
		public class Error{
			public String code;
			public String Detail;
			public String element;
			public String Message;
		}

		public static QBOErrorJSON parse(String json) {
			return (QBOErrorJSON) System.JSON.deserialize(json, QBOErrorJSON.class);
		}
}