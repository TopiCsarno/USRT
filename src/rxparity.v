module rxparity( 	//ParityChecker

  input 		i_Pclk, //clock
  input	[1:0]	i_Parity, //Paritytype
  input [10:0]	i_Data, //input Data
  output [7:0]	o_Data //raw Data out
  output reg	o_ParityOK //Paritycheck result
);

	integer count <= 0;
	integer i <= 1;

  always @ (posedge i_Pclk)
	begin
    	count <= 0;
      for(i=1; i<=9; i=i+1)
    	begin
          if(i_Data[i]==1)
        	count <= count + 1;
	  	end
      case (i_Parity)
        2'b01: begin //even parity
        	if(count%2==0)  
    			o_ParityOK <= 1;
    		else
    			o_ParityOK <= 0;
       		end
        2'b10: begin //odd parity
        	if(count%2==1)  
    			o_ParityOK <= 1;
    		else
    			o_ParityOK <= 0;
        	end
        default: //noparity
        	o_ParityOK<=1;
      endcase
      if(o_ParityOK==1)  
        o_Data <= i_Data[9:2];
      else
    	o_Data <= 0; //parityerror data

	end

endmodule
