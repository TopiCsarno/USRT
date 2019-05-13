module rxparity( 	//ParityChecker
  input 		i_Pclk, //clock
  input     i_Enable, // from shift
  input	[1:0]	i_Parity, //Paritytype
  input [10:0]	i_Data, //input Data
  output [7:0]	o_Data, //raw Data out
  output        o_Enable // push data to rxdat if it is OK
);

  reg r_ParityOK = 0;

	integer count = 0;
	integer i = 1;

  assign o_Data = i_Data[8:1];
  assign o_Enable = i_Enable & r_ParityOK;

  always @ (posedge i_Pclk)
	begin
    	count = 0;
      for(i=1; i<=9; i=i+1)
    	begin
          if(i_Data[i]==1)
        	count = count + 1;
	  	end
      case (i_Parity)
        2'b01: begin //even parity
        	if(count%2==0)  
    			r_ParityOK <= 1;
    		else
    			r_ParityOK <= 0;
       		end
        2'b10: begin //odd parity
        	if(count%2==1)  
    			r_ParityOK <= 1;
    		else
    			r_ParityOK <= 0;
        	end
        default: //noparity
        	r_ParityOK<=1;
      endcase
	end
endmodule
