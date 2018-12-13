clear all
clc
sound = audioread('1.wav');
%Quantizing the levels of the audio into predefined number of levels
L =1024;
max = max(sound);
min = min(sound);
delta = min/((L-1)/2);
levels1 = min:-delta:0;
level1flp = fliplr(levels1);
levels = [ levels1 -level1flp(2:end)];
diff1=0;
% q is the array containing the values of samples after quantizing
q = zeros(1,length(sound));
for i=1:length(sound)
    for j=1:length(levels)
        diff = abs(sound(i)-levels(j));
        if diff < diff1
            q(i)=levels(j);
        end
        diff1=diff;
    end
end

%Getting the probabilities of different symbols or levels
prob = zeros(1,length(levels));
for i=1:length(levels)
    for j=1:length(q)
        if levels(i) == q(j)
            prob(i) = prob(i)+1;
        end
    end
end
prob = prob/length(q);
probval = fliplr(transpose(sortrows(transpose(vertcat(prob,levels)),1)));
probvalind = [probval; 1:length(levels)];
indexofnzero = find(probvalind(1,:));
for i=1:3
    probvalindnew(i,:) = probvalind(i,1:length(indexofnzero));
end
prob = probvalindnew(1,:);
[rows, columns]=size(probvalindnew);

%Applying Huffman coding to the probabilities

field1 = 'f';
value1 = {};
s = struct(field1,value1);

field2 = 'c';
value2 = {};
codes = struct(field2,value2);
for i=1:columns
    codes(i).c = [];
end

for i=1:columns
    s(1,i).f = probvalindnew(1,i);
    s(2,i).f = probvalindnew(3,i);
end

m = 1;
n = 1;
while s(1,1).f ~= 1
    rightind = s(2,columns-m+1).f;
    leftind = s(2,columns-m).f;
    for r=1:length(rightind)
        e = rightind(r);
        codes(1,e).c = [codes(1,e).c 1];
    end
    for r=1:length(leftind)
        codes(leftind(r)).c = [codes(leftind(r)).c 0];
    end
    s(1,columns-m).f = s(1,columns-m).f + s(1,columns-m+1).f;
    s(2,columns-m).f = [s(2,columns-m).f s(2,columns-m+1).f];
    n=m;
    if s(1,1).f ~= 1
        while s(1,columns-n).f > s(1,columns-n-1).f
            buffer1 = s(1,columns-n).f;
            buffer2 = s(2,columns-n).f;
            s(1,columns-n).f = s(1,columns-n-1).f;
            s(2,columns-n).f = s(2,columns-n-1).f;
            s(1,columns-n-1).f = buffer1;
            s(2,columns-n-1).f = buffer2;
            n = n + 1;
            if n==columns-1
                break
            end
        end
    end
    m = m + 1;    
end

for i=1:columns
    codes(i).c = fliplr(codes(i).c);
end

%Calculating entropy
H = 0;
for i=1:columns
    H = H - prob(i)*log2(prob(i));
end
%Calculating average after applying Huffman coding
Lav = 0;
for i=1:columns
    Lav = Lav + prob(i)*length(codes(i).c); 
end
%Calculating the maximum efficiency of Huffman code for this speech signal
Efficiency = (H/Lav)*100;


%Encoding the speech signal
field3 = 'e';
value3 = {};
enc = struct(field3,value3);
for i=1:columns
    rrrr = find(q == probvalindnew(2,i));
    for j=1:length(rrrr)
        enc(1,rrrr(j)).e = codes(1,i).c;
    end
end
encodedsound = [];

for i=1:length(q)
    encodedsound = [encodedsound enc(1,i).e];  
end

%%
%Decoding the speech signal

n=1;
decodedsoundind = [];
for j=1:length(q)
    for i=1:columns
        bool = isequal(codes(1,i).c,encodedsound(n:length(codes(1,i))));
        if bool == 1
           decodedsoundind(j) = i;
           n = n + length(codes(1,i));
           break
        end
    end
end




