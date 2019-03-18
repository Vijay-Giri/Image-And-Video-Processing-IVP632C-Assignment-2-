 
A = imread('lenaTest1.jpg');  
B = imfinfo('lenaTest1.jpg'); 
  
width=B.Width;
height=B.Height;
size_of_block=8;

W=ceil(width/size_of_block);
H=ceil(height/size_of_block);
 

I=zeros(H*size_of_block,W*size_of_block);
I(1:height,1:width)=A(1:height,1:width);
 
%divide numbers into WxH 8x8 matrices
X=zeros(H,W,size_of_block,size_of_block);
for J=1:H
    for K=1:W
        for j=1:size_of_block
            for k=1:size_of_block
                X(J,K,j,k)=I((J-1)*size_of_block+j,(K-1)*size_of_block+k);
            end
        end
    end
end
 
%define luminance quantization matrix
Q=[ 16  11  10  16  24  40  51  61
    12  12  14  19  26  58  60  55
    14  13  16  24  40  57  69  56
    14  17  22  29  51  87  80  62
    18  22  37  56  68  109 103 77
    24  35  55  64  81  104 113 92
    49  64  78  87  103 121 120 101
    72  92  95  98  112 100 103 99];


prompt = 'Input q 30/50/70 \n';
q = input(prompt);

if (q< 50)
    S = 5000/q;
else
    S = 200 - 2*q;
end

Ts = floor((S*Q + 50) / 100);
Ts(Ts == 0) = 1;
Q=Ts;

 Quantized_matrix=zeros(width,height);
 zig_zag=zeros(4096,64);
 count1=1;
 
for J=1:H
    for K=1:W
        Dct=zeros(size_of_block,size_of_block);
        temp=zeros(size_of_block,size_of_block);
        temp(:,:)=X(J,K,:,:);
        temp=double(temp);
        Dct=double(Dct);
        temp=temp-128;
        
        for id1=1:size_of_block
            for id2=1:size_of_block
                value=0;
                for id3=1:size_of_block
                    for id4=1:size_of_block
                       Alpha_u=1;
                       Alpha_v=1;
                       if id1==1
                           Alpha_u=1/sqrt(2);
                       end;
                       if id2==1
                           Alpha_v=1/sqrt(2);
                       end;
                       var=Alpha_u*Alpha_v*temp(id3,id4)/4;
                       theta1=(2*id3-1)*(id1-1)*pi/16;
                       theta2=(2*id4-1)*(id2-1)*pi/16;
                       var=var*cos(theta1)*cos(theta2);
                       value=value+var;
                    end;
                end;
                Dct(id1,id2)=value;
       
            end;
       end;
               
       %Dct=round(Dct/Q); 
       for j_=1:size_of_block
           for k_=1:size_of_block
               Dct(j_,k_)=round(Dct(j_,k_)/Q(j_,k_));
           end;
       end;

       %saving quantized matrix
       for j_=1:size_of_block
           for k_=1:size_of_block
               Quantized_matrix((J-1)*size_of_block+j_,(K-1)*size_of_block+k_)=Dct(j_,k_);
           end;
       end;
        
       idx=1;
 
       %zig zag scanning
       for sum=1:16
           for x_=1:size_of_block;
               for y_=1:size_of_block;
             
                   if x_+y_==sum
                        test=mod(x_+y_,2);
                        if test==0
                           zig_zag(count1,idx)=Dct(y_,x_);
                        end;
                        
                        if test == 1
                           zig_zag(count1,idx)=Dct(x_,y_);
                        end;
                     
                        idx=idx+1;
                   end;
                 
                end;
            end;    
        end;
 
        count1=count1+1;
 
    end;
end;

%Rle implementation 
 Size=1;
 n=512*512;
 stream=[];
 RLE=[];
 row=count1-1;
 coloumn=64;
 for i=1:row
     for j=1:coloumn
        stream(Size)=zig_zag(i,j);
        Size=Size+1;
     end;
 end;
 
 
id=1;
bit=stream;
f=1;
id=1;
for p=1:n-1
  if p==n-1
      if bit(n-1)==bit(n)
         f=f+1;
         RLE(id)=bit(n-1);
         id=id+1;
         RLE(id)=f;
      end;
      if bit(n)~= bit(n-1)
         RLE(id)=bit(n-1);
         id=id+1
         RLE(id)=f;
         id=id+1;
         RLE(id)=bit(n);
         id=id+1;
         f=1;
         RLE(id)=f;
      end;
  else
      if bit(p)==bit(p+1)
         f=f+1;
      end;

      if bit(p)~= bit(p+1)
         RLE(id)=bit(p);
         id=id+1;
         RLE(id)=f;
         id=id+1;
         f=1;
      end;   
    end;
end;
 
chr = string(RLE);
disp(chr.length);
% imwrite(Quantized_matrix,'Quantization.jpeg');
 
if q==30
    imwrite(Quantized_matrix,'Quantization_30.jpeg');
end;
if q==50
    imwrite(Quantized_matrix,'Quantization_50.jpeg');
end;
if q==70
    imwrite(Quantized_matrix,'Quantization_70.jpeg');
end;