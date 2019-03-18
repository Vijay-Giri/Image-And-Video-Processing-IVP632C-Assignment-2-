I=zeros(512,512);

A=imread('lenaTest1.jpg');
for i=1:512
    for j=1:512
        if i<=256
            if j==2*i-1 
                I(i,j)=sqrt(2)/2;
            end;
            if j==2*i
                I(i,j)=sqrt(2)/2;
            end;
       end;
       if i>256
            x=i-256;
            if j==2*x-1
                I(i,j)=-sqrt(2)/2;
            end;
            if j==2*x
                I(i,j)=sqrt(2)/2;
            end;  
       end;
    end;
end;

A=double(A);
Inv=inv(I);
A=I*A*Inv;
imshow(A);

prompt = 'Input threshold \n';
threshold = input(prompt);
for i=1:512
    for j=1:512
        if A(i,j)<threshold
            A(i,j)=0;
        end;
    end;
end;
S=A;

A=inv(I)*A*I;
A=uint8(A);
%imwrite(A,'Assignment2.jpg');
if threshold==15
    imwrite(A,'lena_15.jpg');
end;
if threshold==20
    imwrite(A,'lena_20.jpg');
end;
if threshold==25
    imwrite(A,'lena_25.jpg');
end;
  
    

            