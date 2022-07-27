function [pr, re, fscore] = calc_pr_re_fscore(results, rect_anno, absent_anno, att_anno)
% calculate center distance error and overlap
% seq_length = results.len;
seq_length = size(rect_anno, 1);

% handle the invalided tracking results (NAN, negative and even complex ones)
for i = 2:seq_length
    r = results(i,:);
    r_anno = rect_anno(i,:);
     
    if (sum(isnan(r)) | ~isreal(r) | r(3)<=0 | r(4)<=0) & (~isnan(r_anno))
        results(i,:) = results(i-1,:);
    end
end

rect_mat = results;
rect_mat(1,:) = rect_anno(1,:);  % ignore the result in the first frame

% before evaluation, remove the frames where the target is absent
absent_idx = absent_anno == 1;
rect_mat(absent_idx, :)  = [];

if length(att_anno)> 1 
    att_absent_idx = att_anno == 0;
    rect_mat(att_absent_idx, :)  = [];
    rect_anno(att_absent_idx, :)  = [];
end




end
