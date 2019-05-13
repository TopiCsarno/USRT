module txparity ( //ParityGen
  input 		i_Pclk, //lock
  input	[1:0]	i_Parity, //Paritytype
  input [7:0]	i_Data, //rawData send
  output reg [10:0]	o_Data //Datasend
);
  reg startbit = 0;
  reg stopbit = 1;
  reg paritybit = 0;
  
  integer count = 0;
  integer i = 1;

  always @ (posedge i_Pclk, i_Parity)
	begin
    	count = 0;
      
      for(i=0; i<=7; i=i+1)
    	begin
          if(i_Data[i]==1)
        	count <= count + 1;
	  	end
      
      case (i_Parity)
        2'b01: begin //even parity
        	if(count%2==0)  
    			paritybit <= 0;
    		else
    			paritybit <= 1;
       		end
        2'b10: begin //odd parity
        	if(count%2==1)  
    			paritybit <= 0;
    		else
    			paritybit <= 1;
        	end
        default: //noparity
        	paritybit <= 0;
      endcase
      
      o_Data <= {startbit,i_Data[7:0],paritybit,stopbit };
    end


 
endmodule
