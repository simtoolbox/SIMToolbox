function fnc = getvsmnames(vsmeval)

for I = 1:length(vsmeval)
  fnc(I) = feval(vsmeval(I).fnc);
end