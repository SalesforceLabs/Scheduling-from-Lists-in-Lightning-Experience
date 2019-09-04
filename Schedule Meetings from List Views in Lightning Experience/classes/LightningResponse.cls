/**
* @author Altimetrik
* @description
* started on June 2018
* This class its responsible of the interaction with lightning components
**/
public class LightningResponse {

 	public static final String  SUCCESS_STATE ='SUCCESS';
    public static final String  ERROR_STATE ='ERROR';
	@AuraEnabled public String jsonResponse {get; set;}
	@AuraEnabled public String error {get; set;}
	@AuraEnabled public String state {get; set;}

	/* 
	* @description
	*	Set the current state as Success
	*/
	public LightningResponse() {
		this.state = SUCCESS_STATE;
	}

	/*
	* @description
	*	Set the current state as Error if exist and exception
	*/
	public LightningResponse(Exception e){
		this();
		if(e != null){
			this.state = ERROR_STATE;
			this.error = e.getMessage() +' == '+e.getStackTraceString();
		}
	}

	public LightningResponse(DmlException e) {
		this.state = ERROR_STATE;
		this.error = 'Unknown error';
		if(e != null && e.getDmlMessage(0) != null) {
			this.error = e.getDmlMessage(0);
		}
	}
}