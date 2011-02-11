package {
	class Client {
	    public var banda:Number = 0; 
	    public function onBWCheck(... rest):Number { 
		return 0; 
	    } 
	    public function onBWDone(... rest):void { 
		var p_bw:Number = 0; 
		trace("BIRIBAAA>>> rest.length : " + rest.length);
		if (rest.length > 0){
			if(rest[0] > 0) p_bw = (p_bw + rest[0])/2;
			if(rest[1] > 1) p_bw = (p_bw + rest[1])/2;
			if(rest[2] > 2) p_bw = (p_bw + rest[2])/2;
			if(rest[3] > 3) p_bw = (p_bw + rest[3])/2;
		}
		trace("BIRIBAAA>>> rest 0: " + rest[0]); 
		trace("BIRIBAAA>>> rest 1: " + rest[1]);
		trace("BIRIBAAA>>> rest 2: " + rest[2]);
		trace("BIRIBAAA>>> rest 3: " + rest[3]);
		
		    // your application should do something here 
		    // when the bandwidth check is complete 
		    if((banda > 0) && (p_bw < banda*10) && (banda < p_bw*10)){
		    	banda = Math.round((banda + p_bw)/2);
		    	trace("(IF) bandwidth = " + banda + " Kbps.");
		    }
		    else{
		    	banda = Math.round(p_bw);
		    	trace("(ELSE) bandwidth = " + banda + " Kbps.");
		    }
	    }  
	    public function getBanda():Number {
	    	return banda;
	    }
	}
}
