function [ ssorted ] = sortstruct(s)
probstruc = fliplr(sort([s(1,:).f]));
countr=[];
for i=1:length(probstruc)
    count=1;
    while s(1,i).f ~= probstruc(count)
        count = count + 1;
    end
    countr(i)=count;
end

field = 'ff';
value = {};
ssorted = struct(field,value);
for i=1:length(probstruc)
    ssorted(1,countr(i)).ff = s(1,i).f;
    ssorted(2,countr(i)).ff = s(2,i).f
end



end

