public with sharing class FlowDebugLogger {
    @InvocableMethod(label='Log Debug Message' description='Outputs messages to the debug log')
    public static void trace(List<String> debugMessages) {
        for (String debugMessage : debugMessages) {
            system.debug('Flow Log =>'+debugMessage);
        }
    }
}