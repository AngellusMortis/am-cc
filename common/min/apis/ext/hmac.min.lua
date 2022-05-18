local a=false;local unpack,b,c,d,e,f,g,h,i,j,k,l,m,tonumber,type,n=table.unpack or unpack,table.concat,string.byte,string.char,string.rep,string.sub,string.gsub,string.gmatch,string.format,math.floor,math.ceil,math.min,math.max,tonumber,type,math.huge;local function o(p)local q,r,s,t=0,p,p;while true do q,t,r,s=q+1,r,r+r+1,s+s+q%2;if q>256 or r-(r-1)~=1 or s-(s-1)~=1 or r==s then return q,false elseif r==t then return q,true end end end;local u=2/3;local v=u*5>3 and u*4<3 and o(1.0)>=53;assert(v,"at least 53-bit floating point numbers are required")local w,x=o(1)local y=x and w==64;local z=x and w==32;assert(y or z or not x,"Lua integers must be either 32-bit or 64-bit")local A=({false,[1]=true})[1]and _VERSION~="Luau"and(type(jit)~="table"or jit.version_num>=20000)local B;local C;local D;local E;local F;if A then E=require"bit"F="bit"local G,H=pcall(require,"ffi")if G then D=H end;B=not not loadstring"b=0b0"C=type(jit)=="table"and jit.arch or D and D.arch or nil else for I,J in ipairs(_VERSION=="Lua 5.2"and{"bit32","bit"}or{"bit","bit32"})do if type(_G[J])=="table"and _G[J].bxor then E=_G[J]F=J;break end end end;if a then print("Abilities:")print("   Lua version:               "..(A and"LuaJIT "..(B and"2.1 "or"2.0 ")..(C or"")..(D and" with FFI"or" without FFI")or _VERSION))print("   Integer bitwise operators: "..(y and"int64"or z and"int32"or"no"))print("   32-bit bitwise library:    "..(F or"not found"))end;local K,L;if A and D then K="Using 'ffi' library of LuaJIT"L="FFI"elseif A then K="Using special code for sandboxed LuaJIT (no FFI)"L="LJ"elseif y then K="Using native int64 bitwise operators"L="INT64"elseif z then K="Using native int32 bitwise operators"L="INT32"elseif F then K="Using '"..F.."' library"L="LIB32"else K="Emulating bitwise operators using look-up table"L="EMUL"end;if a then print("Implementation selected:")print("   "..K)end;local M,N,O,P,Q,R,S,T,U,V,W;function P(u,r)return u*2^r%2^32 end;function Q(u,r)u=u%2^32/2^r;return u-u%1 end;function R(u,r)u=u%2^32*2^r;local X=u%2^32;return X+(u-X)/2^32 end;function S(u,r)u=u%2^32/2^r;local X=u%1;return X*2^32+u-X end;local Y={[0]=0}local Z=0;for _=0,127*256,256 do for u=_,_+127 do u=Y[u]*2;Y[Z]=u;Y[Z+1]=u;Y[Z+256]=u;Y[Z+257]=u+1;Z=Z+2 end;Z=Z+256 end;local function a0(u,_,a1)local a2=u%2^32;local a3=_%2^32;local a4=a2%256;local a5=a3%256;local a6=Y[a4+a5*256]u=a2-a4;_=(a3-a5)/256;a4=u%65536;a5=_%256;a6=a6+Y[a4+a5]*256;u=(u-a4)/256;_=(_-a5)/256;a4=u%65536+_%256;a6=a6+Y[a4]*65536;a6=a6+Y[(u+_-a4)/256]*16777216;if a1 then a6=a2+a3-a1*a6 end;return a6 end;function M(u,_)return a0(u,_)end;function N(u,_)return a0(u,_,1)end;function O(u,_,a7,a8,a9)if a7 then if a8 then if a9 then a8=a0(a8,a9,2)end;a7=a0(a7,a8,2)end;_=a0(_,a7,2)end;return a0(u,_,2)end;function W(u,_)return u+_-2*Y[u+_*256]end;V=V or pcall(i,"%x",2^31)and function(u)return i("%08x",u%4294967296)end or function(u)return i("%08x",(u+2^31)%2^32-2^31)end;local function aa(u,_)return O(u,_ or 0xA5A5A5A5)%4294967296 end;local function ab()return{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}end;local ac,ad,ae,af,ag,ah,ai,aj;local ak,al,am,an,ao,ap={},{},{},{},{},{}local aq={[224]={},[256]=an}local ar,as={[384]={},[512]=am},{[384]={},[512]=an}local at,au={},{0x67452301,0xEFCDAB89,0x98BADCFE,0x10325476,0xC3D2E1F0}local av={0,0,0,0,0,0,0,0,28,25,26,27,0,0,10,9,11,12,0,15,16,17,18,0,20,22,23,21}local aw,ax;local ay={}local az,aA,aB=ay,ay,{}local aC,aD,aE=4294967296,0,0;local aF={{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16},{15,11,5,9,10,16,14,7,2,13,1,3,12,8,6,4},{12,9,13,1,6,3,16,14,11,15,4,7,8,2,10,5},{8,10,4,2,14,13,12,15,3,7,6,11,5,1,16,9},{10,1,6,8,3,5,11,16,15,2,12,13,7,9,4,14},{3,13,7,11,1,12,9,4,5,14,8,6,16,15,2,10},{13,6,2,16,15,14,5,11,1,8,7,4,10,3,9,12},{14,12,8,15,13,2,4,10,6,1,16,5,9,7,3,11},{7,16,15,10,12,4,1,9,13,3,14,8,2,5,11,6},{11,3,9,5,8,7,2,6,16,12,10,15,4,13,14,1}}aF[11],aF[12]=aF[1],aF[2]local aG={1,3,4,11,13,10,12,6,1,3,4,11,13,10,2,7,5,8,14,15,16,9,2,7,5,8,14,15}local function aH(aI)local aJ={}for I,aK in ipairs{1,9,13,17,18,21}do aJ[aK]="<"..e(aI,aK)end;return aJ end;if L=="FFI"then local aL=D.new("int32_t[?]",80)aA=aL;aB=D.new("int32_t[?]",16)aG=D.new("uint8_t[?]",#aG+1,0,unpack(aG))for aM=1,10 do aF[aM]=D.new("uint8_t[?]",#aF[aM]+1,0,unpack(aF[aM]))end;aF[11],aF[12]=aF[1],aF[2]function ac(aN,aO,aP,aK)local aQ,aR=aL,al;for aS=aP,aP+aK-1,64 do for aM=0,15 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=N(P(aT,24),P(E,16),P(aU,8),aV)end;for aM=16,63 do local aT,E=aQ[aM-15],aQ[aM-2]aQ[aM]=U(O(S(aT,7),R(aT,14),Q(aT,3))+O(R(E,15),R(E,13),Q(E,10))+aQ[aM-7]+aQ[aM-16])end;local aT,E,aU,aV,aW,aX,aY,aZ=aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]for aM=0,63,8 do local a7=U(O(aY,M(aW,O(aX,aY)))+O(S(aW,6),S(aW,11),R(aW,7))+aQ[aM]+aR[aM+1]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(aY,M(aW,O(aX,aY)))+O(S(aW,6),S(aW,11),R(aW,7))+aQ[aM+1]+aR[aM+2]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(aY,M(aW,O(aX,aY)))+O(S(aW,6),S(aW,11),R(aW,7))+aQ[aM+2]+aR[aM+3]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(aY,M(aW,O(aX,aY)))+O(S(aW,6),S(aW,11),R(aW,7))+aQ[aM+3]+aR[aM+4]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(aY,M(aW,O(aX,aY)))+O(S(aW,6),S(aW,11),R(aW,7))+aQ[aM+4]+aR[aM+5]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(aY,M(aW,O(aX,aY)))+O(S(aW,6),S(aW,11),R(aW,7))+aQ[aM+5]+aR[aM+6]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(aY,M(aW,O(aX,aY)))+O(S(aW,6),S(aW,11),R(aW,7))+aQ[aM+6]+aR[aM+7]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(aY,M(aW,O(aX,aY)))+O(S(aW,6),S(aW,11),R(aW,7))+aQ[aM+7]+aR[aM+8]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)end;aN[1],aN[2],aN[3],aN[4]=U(aT+aN[1]),U(E+aN[2]),U(aU+aN[3]),U(aV+aN[4])aN[5],aN[6],aN[7],aN[8]=U(aW+aN[5]),U(aX+aN[6]),U(aY+aN[7]),U(aZ+aN[8])end end;local a_=D.new("int64_t[?]",80)az=a_;local b0=D.typeof"int64_t"local b1=D.typeof"int32_t"local b2=D.typeof"uint32_t"aD=b0(2^32)if B then local b3,b4,b5,b6,b7,b8,b9,ba=M,N,O,T,P,Q,R,S;aw=V;do local bb=D.new("int64_t[?]",16)local aQ=az;local function bc(aT,E,aU,aV,bd,be)local bf,bg,bh,bi=bb[aT],bb[E],bb[aU],bb[aV]bf=aQ[bd]+bf+bg;bi=ba(b5(bi,bf),32)bh=bh+bi;bg=ba(b5(bg,bh),24)bf=aQ[be]+bf+bg;bi=ba(b5(bi,bf),16)bh=bh+bi;bg=b9(b5(bg,bh),1)bb[aT],bb[E],bb[aU],bb[aV]=bf,bg,bh,bi end;function ai(aN,I,aO,aP,aK,bj,bk,bl)local bm,bn,bo,bp,bq,br,bs,bt=aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]for aS=aP,aP+aK-1,128 do if aO then for aM=1,16 do aS=aS+8;local aT,E,aU,aV,aW,aX,aY,aZ=c(aO,aS-7,aS)aQ[aM]=b5(N(P(aZ,24),P(aY,16),P(aX,8),aW)*b0(2^32),b2(b1(N(P(aV,24),P(aU,16),P(E,8),aT))))end end;bb[0x0],bb[0x1],bb[0x2],bb[0x3],bb[0x4],bb[0x5],bb[0x6],bb[0x7]=bm,bn,bo,bp,bq,br,bs,bt;bb[0x8],bb[0x9],bb[0xA],bb[0xB],bb[0xD],bb[0xE],bb[0xF]=am[1],am[2],am[3],am[4],am[6],am[7],am[8]bj=bj+(bk or 128)bb[0xC]=b5(am[5],bj)if bk then bb[0xE]=b6(bb[0xE])end;if bl then bb[0xF]=b6(bb[0xF])end;for aM=1,12 do local bu=aF[aM]bc(0,4,8,12,bu[1],bu[2])bc(1,5,9,13,bu[3],bu[4])bc(2,6,10,14,bu[5],bu[6])bc(3,7,11,15,bu[7],bu[8])bc(0,5,10,15,bu[9],bu[10])bc(1,6,11,12,bu[11],bu[12])bc(2,7,8,13,bu[13],bu[14])bc(3,4,9,14,bu[15],bu[16])end;bm=b5(bm,bb[0x0],bb[0x8])bn=b5(bn,bb[0x1],bb[0x9])bo=b5(bo,bb[0x2],bb[0xA])bp=b5(bp,bb[0x3],bb[0xB])bq=b5(bq,bb[0x4],bb[0xC])br=b5(br,bb[0x5],bb[0xD])bs=b5(bs,bb[0x6],bb[0xE])bt=b5(bt,bb[0x7],bb[0xF])end;aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]=bm,bn,bo,bp,bq,br,bs,bt;return bj end end;local bv=D.typeof"int64_t[?]"ax=0;aE=b0(2^32)function ab()return bv(30)end;function ag(bw,I,aO,aP,aK,bx)local by=ao;local bz=Q(bx,3)for aS=aP,aP+aK-1,bx do for aM=0,bz-1 do aS=aS+8;local aZ,aY,aX,aW,aV,aU,E,aT=c(aO,aS-7,aS)bw[aM]=b5(bw[aM],b4(N(P(aT,24),P(E,16),P(aU,8),aV)*b0(2^32),b2(b1(N(P(aW,24),P(aX,16),P(aY,8),aZ)))))end;for bA=1,24 do for aM=0,4 do bw[25+aM]=b5(bw[aM],bw[aM+5],bw[aM+10],bw[aM+15],bw[aM+20])end;local bB=b5(bw[25],b9(bw[27],1))bw[1],bw[6],bw[11],bw[16]=b9(b5(bB,bw[6]),44),b9(b5(bB,bw[16]),45),b9(b5(bB,bw[1]),1),b9(b5(bB,bw[11]),10)bw[21]=b9(b5(bB,bw[21]),2)bB=b5(bw[26],b9(bw[28],1))bw[2],bw[7],bw[12],bw[22]=b9(b5(bB,bw[12]),43),b9(b5(bB,bw[22]),61),b9(b5(bB,bw[7]),6),b9(b5(bB,bw[2]),62)bw[17]=b9(b5(bB,bw[17]),15)bB=b5(bw[27],b9(bw[29],1))bw[3],bw[8],bw[18],bw[23]=b9(b5(bB,bw[18]),21),b9(b5(bB,bw[3]),28),b9(b5(bB,bw[23]),56),b9(b5(bB,bw[8]),55)bw[13]=b9(b5(bB,bw[13]),25)bB=b5(bw[28],b9(bw[25],1))bw[4],bw[14],bw[19],bw[24]=b9(b5(bB,bw[24]),14),b9(b5(bB,bw[19]),8),b9(b5(bB,bw[4]),27),b9(b5(bB,bw[14]),39)bw[9]=b9(b5(bB,bw[9]),20)bB=b5(bw[29],b9(bw[26],1))bw[5],bw[10],bw[15],bw[20]=b9(b5(bB,bw[10]),3),b9(b5(bB,bw[20]),18),b9(b5(bB,bw[5]),36),b9(b5(bB,bw[15]),41)bw[0]=b5(bB,bw[0])bw[0],bw[1],bw[2],bw[3],bw[4]=b5(bw[0],b3(b6(bw[1]),bw[2]),by[bA]),b5(bw[1],b3(b6(bw[2]),bw[3])),b5(bw[2],b3(b6(bw[3]),bw[4])),b5(bw[3],b3(b6(bw[4]),bw[0])),b5(bw[4],b3(b6(bw[0]),bw[1]))bw[5],bw[6],bw[7],bw[8],bw[9]=b5(bw[8],b3(b6(bw[9]),bw[5])),b5(bw[9],b3(b6(bw[5]),bw[6])),b5(bw[5],b3(b6(bw[6]),bw[7])),b5(bw[6],b3(b6(bw[7]),bw[8])),b5(bw[7],b3(b6(bw[8]),bw[9]))bw[10],bw[11],bw[12],bw[13],bw[14]=b5(bw[11],b3(b6(bw[12]),bw[13])),b5(bw[12],b3(b6(bw[13]),bw[14])),b5(bw[13],b3(b6(bw[14]),bw[10])),b5(bw[14],b3(b6(bw[10]),bw[11])),b5(bw[10],b3(b6(bw[11]),bw[12]))bw[15],bw[16],bw[17],bw[18],bw[19]=b5(bw[19],b3(b6(bw[15]),bw[16])),b5(bw[15],b3(b6(bw[16]),bw[17])),b5(bw[16],b3(b6(bw[17]),bw[18])),b5(bw[17],b3(b6(bw[18]),bw[19])),b5(bw[18],b3(b6(bw[19]),bw[15]))bw[20],bw[21],bw[22],bw[23],bw[24]=b5(bw[22],b3(b6(bw[23]),bw[24])),b5(bw[23],b3(b6(bw[24]),bw[20])),b5(bw[24],b3(b6(bw[20]),bw[21])),b5(bw[20],b3(b6(bw[21]),bw[22])),b5(bw[21],b3(b6(bw[22]),bw[23]))end end end;local bC=0xA5A5A5A5*b0(2^32+1)function aa(bD,bE)return b5(bD,bE or bC)end;function ad(aN,I,aO,aP,aK)local aQ,aR=a_,ak;for aS=aP,aP+aK-1,128 do for aM=0,15 do aS=aS+8;local aT,E,aU,aV,aW,aX,aY,aZ=c(aO,aS-7,aS)aQ[aM]=b4(N(P(aT,24),P(E,16),P(aU,8),aV)*b0(2^32),b2(b1(N(P(aW,24),P(aX,16),P(aY,8),aZ))))end;for aM=16,79 do local aT,E=aQ[aM-15],aQ[aM-2]aQ[aM]=b5(ba(aT,1),ba(aT,8),b8(aT,7))+b5(ba(E,19),b9(E,3),b8(E,6))+aQ[aM-7]+aQ[aM-16]end;local aT,E,aU,aV,aW,aX,aY,aZ=aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]for aM=0,79,8 do local a7=b5(ba(aW,14),ba(aW,18),b9(aW,23))+b5(aY,b3(aW,b5(aX,aY)))+aZ+aR[aM+1]+aQ[aM]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,b5(b3(b5(aT,E),aU),b3(aT,E))+b5(ba(aT,28),b9(aT,25),b9(aT,30))+a7;a7=b5(ba(aW,14),ba(aW,18),b9(aW,23))+b5(aY,b3(aW,b5(aX,aY)))+aZ+aR[aM+2]+aQ[aM+1]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,b5(b3(b5(aT,E),aU),b3(aT,E))+b5(ba(aT,28),b9(aT,25),b9(aT,30))+a7;a7=b5(ba(aW,14),ba(aW,18),b9(aW,23))+b5(aY,b3(aW,b5(aX,aY)))+aZ+aR[aM+3]+aQ[aM+2]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,b5(b3(b5(aT,E),aU),b3(aT,E))+b5(ba(aT,28),b9(aT,25),b9(aT,30))+a7;a7=b5(ba(aW,14),ba(aW,18),b9(aW,23))+b5(aY,b3(aW,b5(aX,aY)))+aZ+aR[aM+4]+aQ[aM+3]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,b5(b3(b5(aT,E),aU),b3(aT,E))+b5(ba(aT,28),b9(aT,25),b9(aT,30))+a7;a7=b5(ba(aW,14),ba(aW,18),b9(aW,23))+b5(aY,b3(aW,b5(aX,aY)))+aZ+aR[aM+5]+aQ[aM+4]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,b5(b3(b5(aT,E),aU),b3(aT,E))+b5(ba(aT,28),b9(aT,25),b9(aT,30))+a7;a7=b5(ba(aW,14),ba(aW,18),b9(aW,23))+b5(aY,b3(aW,b5(aX,aY)))+aZ+aR[aM+6]+aQ[aM+5]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,b5(b3(b5(aT,E),aU),b3(aT,E))+b5(ba(aT,28),b9(aT,25),b9(aT,30))+a7;a7=b5(ba(aW,14),ba(aW,18),b9(aW,23))+b5(aY,b3(aW,b5(aX,aY)))+aZ+aR[aM+7]+aQ[aM+6]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,b5(b3(b5(aT,E),aU),b3(aT,E))+b5(ba(aT,28),b9(aT,25),b9(aT,30))+a7;a7=b5(ba(aW,14),ba(aW,18),b9(aW,23))+b5(aY,b3(aW,b5(aX,aY)))+aZ+aR[aM+8]+aQ[aM+7]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,b5(b3(b5(aT,E),aU),b3(aT,E))+b5(ba(aT,28),b9(aT,25),b9(aT,30))+a7 end;aN[1]=aT+aN[1]aN[2]=E+aN[2]aN[3]=aU+aN[3]aN[4]=aV+aN[4]aN[5]=aW+aN[5]aN[6]=aX+aN[6]aN[7]=aY+aN[7]aN[8]=aZ+aN[8]end end else local bF=D.new("union{int64_t i64; struct{int32_t "..(D.abi("le")and"lo, hi"or"hi, lo")..";} i32;}[3]")local function bG(aT)bF[0].i64=aT;local bH,bI=bF[0].i32.lo,bF[0].i32.hi;local bJ=O(Q(bH,1),P(bI,31),Q(bH,8),P(bI,24),Q(bH,7),P(bI,25))local bK=O(Q(bI,1),P(bH,31),Q(bI,8),P(bH,24),Q(bI,7))return bK*b0(2^32)+b2(b1(bJ))end;local function bL(E)bF[0].i64=E;local bM,bN=bF[0].i32.lo,bF[0].i32.hi;local bO=O(Q(bM,19),P(bN,13),P(bM,3),Q(bN,29),Q(bM,6),P(bN,26))local bP=O(Q(bN,19),P(bM,13),P(bN,3),Q(bM,29),Q(bN,6))return bP*b0(2^32)+b2(b1(bO))end;local function bQ(aW)bF[0].i64=aW;local bR,bS=bF[0].i32.lo,bF[0].i32.hi;local bO=O(Q(bR,14),P(bS,18),Q(bR,18),P(bS,14),P(bR,23),Q(bS,9))local bP=O(Q(bS,14),P(bR,18),Q(bS,18),P(bR,14),P(bS,23),Q(bR,9))return bP*b0(2^32)+b2(b1(bO))end;local function bT(aT)bF[0].i64=aT;local bM,bN=bF[0].i32.lo,bF[0].i32.hi;local bO=O(Q(bM,28),P(bN,4),P(bM,30),Q(bN,2),P(bM,25),Q(bN,7))local bP=O(Q(bN,28),P(bM,4),P(bN,30),Q(bM,2),P(bN,25),Q(bM,7))return bP*b0(2^32)+b2(b1(bO))end;local function bU(aW,aX,aY)bF[0].i64=aX;bF[1].i64=aY;bF[2].i64=aW;local bV,bW=bF[0].i32.lo,bF[0].i32.hi;local bX,bY=bF[1].i32.lo,bF[1].i32.hi;local bR,bS=bF[2].i32.lo,bF[2].i32.hi;local bZ=O(bX,M(bR,O(bV,bX)))local b_=O(bY,M(bS,O(bW,bY)))return b_*b0(2^32)+b2(b1(bZ))end;local function c0(aT,E,aU)bF[0].i64=aT;bF[1].i64=E;bF[2].i64=aU;local bH,bI=bF[0].i32.lo,bF[0].i32.hi;local bM,bN=bF[1].i32.lo,bF[1].i32.hi;local c1,c2=bF[2].i32.lo,bF[2].i32.hi;local bZ=O(M(O(bH,bM),c1),M(bH,bM))local b_=O(M(O(bI,bN),c2),M(bI,bN))return b_*b0(2^32)+b2(b1(bZ))end;local function c3(aT,E,s)bF[0].i64=aT;bF[1].i64=E;local bH,bI=bF[0].i32.lo,bF[0].i32.hi;local bM,bN=bF[1].i32.lo,bF[1].i32.hi;local c1,c2=O(bH,bM),O(bI,bN)local bJ=O(Q(c1,s),P(c2,-s))local bK=O(Q(c2,s),P(c1,-s))return bK*b0(2^32)+b2(b1(bJ))end;local function c4(aT,E)bF[0].i64=aT;bF[1].i64=E;local bH,bI=bF[0].i32.lo,bF[0].i32.hi;local bM,bN=bF[1].i32.lo,bF[1].i32.hi;local c1,c2=O(bH,bM),O(bI,bN)local bJ=O(P(c1,1),Q(c2,31))local bK=O(P(c2,1),Q(c1,31))return bK*b0(2^32)+b2(b1(bJ))end;local function c5(aT,E)bF[0].i64=aT;bF[1].i64=E;local bH,bI=bF[0].i32.lo,bF[0].i32.hi;local bM,bN=bF[1].i32.lo,bF[1].i32.hi;local bK,bJ=O(bH,bM),O(bI,bN)return bK*b0(2^32)+b2(b1(bJ))end;local function b5(aT,E)bF[0].i64=aT;bF[1].i64=E;local bH,bI=bF[0].i32.lo,bF[0].i32.hi;local bM,bN=bF[1].i32.lo,bF[1].i32.hi;local bJ,bK=O(bH,bM),O(bI,bN)return bK*b0(2^32)+b2(b1(bJ))end;local function c6(aT,E,aU)bF[0].i64=aT;bF[1].i64=E;bF[2].i64=aU;local bH,bI=bF[0].i32.lo,bF[0].i32.hi;local bM,bN=bF[1].i32.lo,bF[1].i32.hi;local c1,c2=bF[2].i32.lo,bF[2].i32.hi;local bJ,bK=O(bH,bM,c1),O(bI,bN,c2)return bK*b0(2^32)+b2(b1(bJ))end;function aa(bD,bE)bF[0].i64=bD;local c7,c8=bF[0].i32.lo,bF[0].i32.hi;local c9,ca=0xA5A5A5A5,0xA5A5A5A5;if bE then bF[1].i64=bE;c9,ca=bF[1].i32.lo,bF[1].i32.hi end;c7=O(c7,c9)c8=O(c8,ca)return c8*b0(2^32)+b2(b1(c7))end;function aw(bD)bF[0].i64=bD;return V(bF[0].i32.hi)..V(bF[0].i32.lo)end;function ad(aN,I,aO,aP,aK)local aQ,aR=a_,ak;for aS=aP,aP+aK-1,128 do for aM=0,15 do aS=aS+8;local aT,E,aU,aV,aW,aX,aY,aZ=c(aO,aS-7,aS)aQ[aM]=N(P(aT,24),P(E,16),P(aU,8),aV)*b0(2^32)+b2(b1(N(P(aW,24),P(aX,16),P(aY,8),aZ)))end;for aM=16,79 do aQ[aM]=bG(aQ[aM-15])+bL(aQ[aM-2])+aQ[aM-7]+aQ[aM-16]end;local aT,E,aU,aV,aW,aX,aY,aZ=aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]for aM=0,79,8 do local a7=bQ(aW)+bU(aW,aX,aY)+aZ+aR[aM+1]+aQ[aM]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,c0(aT,E,aU)+bT(aT)+a7;a7=bQ(aW)+bU(aW,aX,aY)+aZ+aR[aM+2]+aQ[aM+1]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,c0(aT,E,aU)+bT(aT)+a7;a7=bQ(aW)+bU(aW,aX,aY)+aZ+aR[aM+3]+aQ[aM+2]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,c0(aT,E,aU)+bT(aT)+a7;a7=bQ(aW)+bU(aW,aX,aY)+aZ+aR[aM+4]+aQ[aM+3]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,c0(aT,E,aU)+bT(aT)+a7;a7=bQ(aW)+bU(aW,aX,aY)+aZ+aR[aM+5]+aQ[aM+4]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,c0(aT,E,aU)+bT(aT)+a7;a7=bQ(aW)+bU(aW,aX,aY)+aZ+aR[aM+6]+aQ[aM+5]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,c0(aT,E,aU)+bT(aT)+a7;a7=bQ(aW)+bU(aW,aX,aY)+aZ+aR[aM+7]+aQ[aM+6]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,c0(aT,E,aU)+bT(aT)+a7;a7=bQ(aW)+bU(aW,aX,aY)+aZ+aR[aM+8]+aQ[aM+7]aZ,aY,aX,aW=aY,aX,aW,a7+aV;aV,aU,E,aT=aU,E,aT,c0(aT,E,aU)+bT(aT)+a7 end;aN[1]=aT+aN[1]aN[2]=E+aN[2]aN[3]=aU+aN[3]aN[4]=aV+aN[4]aN[5]=aW+aN[5]aN[6]=aX+aN[6]aN[7]=aY+aN[7]aN[8]=aZ+aN[8]end end;do local bb=D.new("int64_t[?]",16)local aQ=az;local function bc(aT,E,aU,aV,bd,be)local bf,bg,bh,bi=bb[aT],bb[E],bb[aU],bb[aV]bf=aQ[bd]+bf+bg;bi=c5(bi,bf)bh=bh+bi;bg=c3(bg,bh,24)bf=aQ[be]+bf+bg;bi=c3(bi,bf,16)bh=bh+bi;bg=c4(bg,bh)bb[aT],bb[E],bb[aU],bb[aV]=bf,bg,bh,bi end;function ai(aN,I,aO,aP,aK,bj,bk,bl)local bm,bn,bo,bp,bq,br,bs,bt=aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]for aS=aP,aP+aK-1,128 do if aO then for aM=1,16 do aS=aS+8;local aT,E,aU,aV,aW,aX,aY,aZ=c(aO,aS-7,aS)aQ[aM]=b5(N(P(aZ,24),P(aY,16),P(aX,8),aW)*b0(2^32),b2(b1(N(P(aV,24),P(aU,16),P(E,8),aT))))end end;bb[0x0],bb[0x1],bb[0x2],bb[0x3],bb[0x4],bb[0x5],bb[0x6],bb[0x7]=bm,bn,bo,bp,bq,br,bs,bt;bb[0x8],bb[0x9],bb[0xA],bb[0xB],bb[0xD],bb[0xE],bb[0xF]=am[1],am[2],am[3],am[4],am[6],am[7],am[8]bj=bj+(bk or 128)bb[0xC]=b5(am[5],bj)if bk then bb[0xE]=-1-bb[0xE]end;if bl then bb[0xF]=-1-bb[0xF]end;for aM=1,12 do local bu=aF[aM]bc(0,4,8,12,bu[1],bu[2])bc(1,5,9,13,bu[3],bu[4])bc(2,6,10,14,bu[5],bu[6])bc(3,7,11,15,bu[7],bu[8])bc(0,5,10,15,bu[9],bu[10])bc(1,6,11,12,bu[11],bu[12])bc(2,7,8,13,bu[13],bu[14])bc(3,4,9,14,bu[15],bu[16])end;bm=c6(bm,bb[0x0],bb[0x8])bn=c6(bn,bb[0x1],bb[0x9])bo=c6(bo,bb[0x2],bb[0xA])bp=c6(bp,bb[0x3],bb[0xB])bq=c6(bq,bb[0x4],bb[0xC])br=c6(br,bb[0x5],bb[0xD])bs=c6(bs,bb[0x6],bb[0xE])bt=c6(bt,bb[0x7],bb[0xF])end;aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]=bm,bn,bo,bp,bq,br,bs,bt;return bj end end end;function ae(aN,aO,aP,aK)local aQ,aR=aL,at;for aS=aP,aP+aK-1,64 do for aM=0,15 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=N(P(aV,24),P(aU,16),P(E,8),aT)end;local aT,E,aU,aV=aN[1],aN[2],aN[3],aN[4]for aM=0,15,4 do aT,aV,aU,E=aV,aU,E,U(R(O(aV,M(E,O(aU,aV)))+aR[aM+1]+aQ[aM]+aT,7)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aV,M(E,O(aU,aV)))+aR[aM+2]+aQ[aM+1]+aT,12)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aV,M(E,O(aU,aV)))+aR[aM+3]+aQ[aM+2]+aT,17)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aV,M(E,O(aU,aV)))+aR[aM+4]+aQ[aM+3]+aT,22)+E)end;for aM=16,31,4 do local aY=5*aM;aT,aV,aU,E=aV,aU,E,U(R(O(aU,M(aV,O(E,aU)))+aR[aM+1]+aQ[M(aY+1,15)]+aT,5)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,M(aV,O(E,aU)))+aR[aM+2]+aQ[M(aY+6,15)]+aT,9)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,M(aV,O(E,aU)))+aR[aM+3]+aQ[M(aY-5,15)]+aT,14)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,M(aV,O(E,aU)))+aR[aM+4]+aQ[M(aY,15)]+aT,20)+E)end;for aM=32,47,4 do local aY=3*aM;aT,aV,aU,E=aV,aU,E,U(R(O(E,aU,aV)+aR[aM+1]+aQ[M(aY+5,15)]+aT,4)+E)aT,aV,aU,E=aV,aU,E,U(R(O(E,aU,aV)+aR[aM+2]+aQ[M(aY+8,15)]+aT,11)+E)aT,aV,aU,E=aV,aU,E,U(R(O(E,aU,aV)+aR[aM+3]+aQ[M(aY-5,15)]+aT,16)+E)aT,aV,aU,E=aV,aU,E,U(R(O(E,aU,aV)+aR[aM+4]+aQ[M(aY-2,15)]+aT,23)+E)end;for aM=48,63,4 do local aY=7*aM;aT,aV,aU,E=aV,aU,E,U(R(O(aU,N(E,T(aV)))+aR[aM+1]+aQ[M(aY,15)]+aT,6)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,N(E,T(aV)))+aR[aM+2]+aQ[M(aY+7,15)]+aT,10)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,N(E,T(aV)))+aR[aM+3]+aQ[M(aY-2,15)]+aT,15)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,N(E,T(aV)))+aR[aM+4]+aQ[M(aY+5,15)]+aT,21)+E)end;aN[1],aN[2],aN[3],aN[4]=U(aT+aN[1]),U(E+aN[2]),U(aU+aN[3]),U(aV+aN[4])end end;function af(aN,aO,aP,aK)local aQ=aL;for aS=aP,aP+aK-1,64 do for aM=0,15 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=N(P(aT,24),P(E,16),P(aU,8),aV)end;for aM=16,79 do aQ[aM]=R(O(aQ[aM-3],aQ[aM-8],aQ[aM-14],aQ[aM-16]),1)end;local aT,E,aU,aV,aW=aN[1],aN[2],aN[3],aN[4],aN[5]for aM=0,19,5 do aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(aV,M(E,O(aV,aU)))+aQ[aM]+0x5A827999+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(aV,M(E,O(aV,aU)))+aQ[aM+1]+0x5A827999+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(aV,M(E,O(aV,aU)))+aQ[aM+2]+0x5A827999+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(aV,M(E,O(aV,aU)))+aQ[aM+3]+0x5A827999+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(aV,M(E,O(aV,aU)))+aQ[aM+4]+0x5A827999+aW)end;for aM=20,39,5 do aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM]+0x6ED9EBA1+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+1]+0x6ED9EBA1+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+2]+0x6ED9EBA1+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+3]+0x6ED9EBA1+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+4]+0x6ED9EBA1+aW)end;for aM=40,59,5 do aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(M(aV,O(E,aU)),M(E,aU))+aQ[aM]+0x8F1BBCDC+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(M(aV,O(E,aU)),M(E,aU))+aQ[aM+1]+0x8F1BBCDC+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(M(aV,O(E,aU)),M(E,aU))+aQ[aM+2]+0x8F1BBCDC+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(M(aV,O(E,aU)),M(E,aU))+aQ[aM+3]+0x8F1BBCDC+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(M(aV,O(E,aU)),M(E,aU))+aQ[aM+4]+0x8F1BBCDC+aW)end;for aM=60,79,5 do aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM]+0xCA62C1D6+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+1]+0xCA62C1D6+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+2]+0xCA62C1D6+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+3]+0xCA62C1D6+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+4]+0xCA62C1D6+aW)end;aN[1],aN[2],aN[3],aN[4],aN[5]=U(aT+aN[1]),U(E+aN[2]),U(aU+aN[3]),U(aV+aN[4]),U(aW+aN[5])end end end;if L=="FFI"and not B or L=="LJ"then if L=="FFI"then local cb=D.typeof"int32_t[?]"function ab()return cb(31)end end;function ag(cc,cd,aO,aP,aK,bx)local ce,cf=ao,ap;local bz=Q(bx,3)for aS=aP,aP+aK-1,bx do for aM=1,bz do local aT,E,aU,aV=c(aO,aS+1,aS+4)cc[aM]=O(cc[aM],N(P(aV,24),P(aU,16),P(E,8),aT))aS=aS+8;aT,E,aU,aV=c(aO,aS-3,aS)cd[aM]=O(cd[aM],N(P(aV,24),P(aU,16),P(E,8),aT))end;for bA=1,24 do for aM=1,5 do cc[25+aM]=O(cc[aM],cc[aM+5],cc[aM+10],cc[aM+15],cc[aM+20])end;for aM=1,5 do cd[25+aM]=O(cd[aM],cd[aM+5],cd[aM+10],cd[aM+15],cd[aM+20])end;local cg=O(cc[26],P(cc[28],1),Q(cd[28],31))local ch=O(cd[26],P(cd[28],1),Q(cc[28],31))cc[2],cd[2],cc[7],cd[7],cc[12],cd[12],cc[17],cd[17]=O(Q(O(cg,cc[7]),20),P(O(ch,cd[7]),12)),O(Q(O(ch,cd[7]),20),P(O(cg,cc[7]),12)),O(Q(O(cg,cc[17]),19),P(O(ch,cd[17]),13)),O(Q(O(ch,cd[17]),19),P(O(cg,cc[17]),13)),O(P(O(cg,cc[2]),1),Q(O(ch,cd[2]),31)),O(P(O(ch,cd[2]),1),Q(O(cg,cc[2]),31)),O(P(O(cg,cc[12]),10),Q(O(ch,cd[12]),22)),O(P(O(ch,cd[12]),10),Q(O(cg,cc[12]),22))local ci,aN=O(cg,cc[22]),O(ch,cd[22])cc[22],cd[22]=O(P(ci,2),Q(aN,30)),O(P(aN,2),Q(ci,30))cg=O(cc[27],P(cc[29],1),Q(cd[29],31))ch=O(cd[27],P(cd[29],1),Q(cc[29],31))cc[3],cd[3],cc[8],cd[8],cc[13],cd[13],cc[23],cd[23]=O(Q(O(cg,cc[13]),21),P(O(ch,cd[13]),11)),O(Q(O(ch,cd[13]),21),P(O(cg,cc[13]),11)),O(Q(O(cg,cc[23]),3),P(O(ch,cd[23]),29)),O(Q(O(ch,cd[23]),3),P(O(cg,cc[23]),29)),O(P(O(cg,cc[8]),6),Q(O(ch,cd[8]),26)),O(P(O(ch,cd[8]),6),Q(O(cg,cc[8]),26)),O(Q(O(cg,cc[3]),2),P(O(ch,cd[3]),30)),O(Q(O(ch,cd[3]),2),P(O(cg,cc[3]),30))ci,aN=O(cg,cc[18]),O(ch,cd[18])cc[18],cd[18]=O(P(ci,15),Q(aN,17)),O(P(aN,15),Q(ci,17))cg=O(cc[28],P(cc[30],1),Q(cd[30],31))ch=O(cd[28],P(cd[30],1),Q(cc[30],31))cc[4],cd[4],cc[9],cd[9],cc[19],cd[19],cc[24],cd[24]=O(P(O(cg,cc[19]),21),Q(O(ch,cd[19]),11)),O(P(O(ch,cd[19]),21),Q(O(cg,cc[19]),11)),O(P(O(cg,cc[4]),28),Q(O(ch,cd[4]),4)),O(P(O(ch,cd[4]),28),Q(O(cg,cc[4]),4)),O(Q(O(cg,cc[24]),8),P(O(ch,cd[24]),24)),O(Q(O(ch,cd[24]),8),P(O(cg,cc[24]),24)),O(Q(O(cg,cc[9]),9),P(O(ch,cd[9]),23)),O(Q(O(ch,cd[9]),9),P(O(cg,cc[9]),23))ci,aN=O(cg,cc[14]),O(ch,cd[14])cc[14],cd[14]=O(P(ci,25),Q(aN,7)),O(P(aN,25),Q(ci,7))cg=O(cc[29],P(cc[26],1),Q(cd[26],31))ch=O(cd[29],P(cd[26],1),Q(cc[26],31))cc[5],cd[5],cc[15],cd[15],cc[20],cd[20],cc[25],cd[25]=O(P(O(cg,cc[25]),14),Q(O(ch,cd[25]),18)),O(P(O(ch,cd[25]),14),Q(O(cg,cc[25]),18)),O(P(O(cg,cc[20]),8),Q(O(ch,cd[20]),24)),O(P(O(ch,cd[20]),8),Q(O(cg,cc[20]),24)),O(P(O(cg,cc[5]),27),Q(O(ch,cd[5]),5)),O(P(O(ch,cd[5]),27),Q(O(cg,cc[5]),5)),O(Q(O(cg,cc[15]),25),P(O(ch,cd[15]),7)),O(Q(O(ch,cd[15]),25),P(O(cg,cc[15]),7))ci,aN=O(cg,cc[10]),O(ch,cd[10])cc[10],cd[10]=O(P(ci,20),Q(aN,12)),O(P(aN,20),Q(ci,12))cg=O(cc[30],P(cc[27],1),Q(cd[27],31))ch=O(cd[30],P(cd[27],1),Q(cc[27],31))cc[6],cd[6],cc[11],cd[11],cc[16],cd[16],cc[21],cd[21]=O(P(O(cg,cc[11]),3),Q(O(ch,cd[11]),29)),O(P(O(ch,cd[11]),3),Q(O(cg,cc[11]),29)),O(P(O(cg,cc[21]),18),Q(O(ch,cd[21]),14)),O(P(O(ch,cd[21]),18),Q(O(cg,cc[21]),14)),O(Q(O(cg,cc[6]),28),P(O(ch,cd[6]),4)),O(Q(O(ch,cd[6]),28),P(O(cg,cc[6]),4)),O(Q(O(cg,cc[16]),23),P(O(ch,cd[16]),9)),O(Q(O(ch,cd[16]),23),P(O(cg,cc[16]),9))cc[1],cd[1]=O(cg,cc[1]),O(ch,cd[1])cc[1],cc[2],cc[3],cc[4],cc[5]=O(cc[1],M(T(cc[2]),cc[3]),ce[bA]),O(cc[2],M(T(cc[3]),cc[4])),O(cc[3],M(T(cc[4]),cc[5])),O(cc[4],M(T(cc[5]),cc[1])),O(cc[5],M(T(cc[1]),cc[2]))cc[6],cc[7],cc[8],cc[9],cc[10]=O(cc[9],M(T(cc[10]),cc[6])),O(cc[10],M(T(cc[6]),cc[7])),O(cc[6],M(T(cc[7]),cc[8])),O(cc[7],M(T(cc[8]),cc[9])),O(cc[8],M(T(cc[9]),cc[10]))cc[11],cc[12],cc[13],cc[14],cc[15]=O(cc[12],M(T(cc[13]),cc[14])),O(cc[13],M(T(cc[14]),cc[15])),O(cc[14],M(T(cc[15]),cc[11])),O(cc[15],M(T(cc[11]),cc[12])),O(cc[11],M(T(cc[12]),cc[13]))cc[16],cc[17],cc[18],cc[19],cc[20]=O(cc[20],M(T(cc[16]),cc[17])),O(cc[16],M(T(cc[17]),cc[18])),O(cc[17],M(T(cc[18]),cc[19])),O(cc[18],M(T(cc[19]),cc[20])),O(cc[19],M(T(cc[20]),cc[16]))cc[21],cc[22],cc[23],cc[24],cc[25]=O(cc[23],M(T(cc[24]),cc[25])),O(cc[24],M(T(cc[25]),cc[21])),O(cc[25],M(T(cc[21]),cc[22])),O(cc[21],M(T(cc[22]),cc[23])),O(cc[22],M(T(cc[23]),cc[24]))cd[1],cd[2],cd[3],cd[4],cd[5]=O(cd[1],M(T(cd[2]),cd[3]),cf[bA]),O(cd[2],M(T(cd[3]),cd[4])),O(cd[3],M(T(cd[4]),cd[5])),O(cd[4],M(T(cd[5]),cd[1])),O(cd[5],M(T(cd[1]),cd[2]))cd[6],cd[7],cd[8],cd[9],cd[10]=O(cd[9],M(T(cd[10]),cd[6])),O(cd[10],M(T(cd[6]),cd[7])),O(cd[6],M(T(cd[7]),cd[8])),O(cd[7],M(T(cd[8]),cd[9])),O(cd[8],M(T(cd[9]),cd[10]))cd[11],cd[12],cd[13],cd[14],cd[15]=O(cd[12],M(T(cd[13]),cd[14])),O(cd[13],M(T(cd[14]),cd[15])),O(cd[14],M(T(cd[15]),cd[11])),O(cd[15],M(T(cd[11]),cd[12])),O(cd[11],M(T(cd[12]),cd[13]))cd[16],cd[17],cd[18],cd[19],cd[20]=O(cd[20],M(T(cd[16]),cd[17])),O(cd[16],M(T(cd[17]),cd[18])),O(cd[17],M(T(cd[18]),cd[19])),O(cd[18],M(T(cd[19]),cd[20])),O(cd[19],M(T(cd[20]),cd[16]))cd[21],cd[22],cd[23],cd[24],cd[25]=O(cd[23],M(T(cd[24]),cd[25])),O(cd[24],M(T(cd[25]),cd[21])),O(cd[25],M(T(cd[21]),cd[22])),O(cd[21],M(T(cd[22]),cd[23])),O(cd[22],M(T(cd[23]),cd[24]))end end end end;if L=="LJ"then function ac(aN,aO,aP,aK)local aQ,aR=ay,al;for aS=aP,aP+aK-1,64 do for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=N(P(aT,24),P(E,16),P(aU,8),aV)end;for aM=17,64 do local aT,E=aQ[aM-15],aQ[aM-2]aQ[aM]=U(U(O(S(aT,7),R(aT,14),Q(aT,3))+O(R(E,15),R(E,13),Q(E,10)))+U(aQ[aM-7]+aQ[aM-16]))end;local aT,E,aU,aV,aW,aX,aY,aZ=aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]for aM=1,64,8 do local a7=U(O(S(aW,6),S(aW,11),R(aW,7))+O(aY,M(aW,O(aX,aY)))+aR[aM]+aQ[aM]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(S(aW,6),S(aW,11),R(aW,7))+O(aY,M(aW,O(aX,aY)))+aR[aM+1]+aQ[aM+1]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(S(aW,6),S(aW,11),R(aW,7))+O(aY,M(aW,O(aX,aY)))+aR[aM+2]+aQ[aM+2]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(S(aW,6),S(aW,11),R(aW,7))+O(aY,M(aW,O(aX,aY)))+aR[aM+3]+aQ[aM+3]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(S(aW,6),S(aW,11),R(aW,7))+O(aY,M(aW,O(aX,aY)))+aR[aM+4]+aQ[aM+4]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(S(aW,6),S(aW,11),R(aW,7))+O(aY,M(aW,O(aX,aY)))+aR[aM+5]+aQ[aM+5]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(S(aW,6),S(aW,11),R(aW,7))+O(aY,M(aW,O(aX,aY)))+aR[aM+6]+aQ[aM+6]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)a7=U(O(S(aW,6),S(aW,11),R(aW,7))+O(aY,M(aW,O(aX,aY)))+aR[aM+7]+aQ[aM+7]+aZ)aZ,aY,aX,aW=aY,aX,aW,U(aV+a7)aV,aU,E,aT=aU,E,aT,U(O(M(aT,O(E,aU)),M(E,aU))+O(S(aT,2),S(aT,13),R(aT,10))+a7)end;aN[1],aN[2],aN[3],aN[4]=U(aT+aN[1]),U(E+aN[2]),U(aU+aN[3]),U(aV+aN[4])aN[5],aN[6],aN[7],aN[8]=U(aW+aN[5]),U(aX+aN[6]),U(aY+aN[7]),U(aZ+aN[8])end end;local function cj(bH,bI,bM,bN,c1,c2,ck,cl)local cm=bH%2^32+bM%2^32+c1%2^32+ck%2^32;local cn=bI+bN+c2+cl;local bZ=U(cm)local b_=U(cn+j(cm/2^32))return bZ,b_ end;if C=="x86"then function ad(co,cp,aO,aP,aK)local aQ,cq,cr=ay,ak,al;for aS=aP,aP+aK-1,128 do for aM=1,16*2 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=N(P(aT,24),P(E,16),P(aU,8),aV)end;for cs=17*2,80*2,2 do local bH,bI=aQ[cs-30],aQ[cs-31]local bJ=O(N(Q(bH,1),P(bI,31)),N(Q(bH,8),P(bI,24)),N(Q(bH,7),P(bI,25)))local bK=O(N(Q(bI,1),P(bH,31)),N(Q(bI,8),P(bH,24)),Q(bI,7))local bM,bN=aQ[cs-4],aQ[cs-5]local bO=O(N(Q(bM,19),P(bN,13)),N(P(bM,3),Q(bN,29)),N(Q(bM,6),P(bN,26)))local bP=O(N(Q(bN,19),P(bM,13)),N(P(bN,3),Q(bM,29)),Q(bN,6))aQ[cs],aQ[cs-1]=cj(bJ,bK,bO,bP,aQ[cs-14],aQ[cs-15],aQ[cs-32],aQ[cs-33])end;local bH,bM,c1,ck,bR,bV,bX,ct=co[1],co[2],co[3],co[4],co[5],co[6],co[7],co[8]local bI,bN,c2,cl,bS,bW,bY,cu=cp[1],cp[2],cp[3],cp[4],cp[5],cp[6],cp[7],cp[8]local cv=0;for aM=1,80 do local bJ=O(bX,M(bR,O(bV,bX)))local bK=O(bY,M(bS,O(bW,bY)))local bO=O(N(Q(bR,14),P(bS,18)),N(Q(bR,18),P(bS,14)),N(P(bR,23),Q(bS,9)))local bP=O(N(Q(bS,14),P(bR,18)),N(Q(bS,18),P(bR,14)),N(P(bS,23),Q(bR,9)))local cm=bO%2^32+bJ%2^32+ct%2^32+cq[aM]+aQ[2*aM]%2^32;local cw,cx=U(cm),U(bP+bK+cu+cr[aM]+aQ[2*aM-1]+j(cm/2^32))cv=cv+cv;ct,cu,bX,bY,bV,bW=N(cv,bX),N(cv,bY),N(cv,bV),N(cv,bW),N(cv,bR),N(cv,bS)local cm=cw%2^32+ck%2^32;bR,bS=U(cm),U(cx+cl+j(cm/2^32))ck,cl,c1,c2,bM,bN=N(cv,c1),N(cv,c2),N(cv,bM),N(cv,bN),N(cv,bH),N(cv,bI)bO=O(N(Q(bM,28),P(bN,4)),N(P(bM,30),Q(bN,2)),N(P(bM,25),Q(bN,7)))bP=O(N(Q(bN,28),P(bM,4)),N(P(bN,30),Q(bM,2)),N(P(bN,25),Q(bM,7)))bJ=N(M(ck,c1),M(bM,O(ck,c1)))bK=N(M(cl,c2),M(bN,O(cl,c2)))local cm=cw%2^32+bJ%2^32+bO%2^32;bH,bI=U(cm),U(cx+bK+bP+j(cm/2^32))end;co[1],cp[1]=cj(co[1],cp[1],bH,bI,0,0,0,0)co[2],cp[2]=cj(co[2],cp[2],bM,bN,0,0,0,0)co[3],cp[3]=cj(co[3],cp[3],c1,c2,0,0,0,0)co[4],cp[4]=cj(co[4],cp[4],ck,cl,0,0,0,0)co[5],cp[5]=cj(co[5],cp[5],bR,bS,0,0,0,0)co[6],cp[6]=cj(co[6],cp[6],bV,bW,0,0,0,0)co[7],cp[7]=cj(co[7],cp[7],bX,bY,0,0,0,0)co[8],cp[8]=cj(co[8],cp[8],ct,cu,0,0,0,0)end end else function ad(co,cp,aO,aP,aK)local aQ,cq,cr=ay,ak,al;for aS=aP,aP+aK-1,128 do for aM=1,16*2 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=N(P(aT,24),P(E,16),P(aU,8),aV)end;for cs=17*2,80*2,2 do local bH,bI=aQ[cs-30],aQ[cs-31]local bJ=O(N(Q(bH,1),P(bI,31)),N(Q(bH,8),P(bI,24)),N(Q(bH,7),P(bI,25)))local bK=O(N(Q(bI,1),P(bH,31)),N(Q(bI,8),P(bH,24)),Q(bI,7))local bM,bN=aQ[cs-4],aQ[cs-5]local bO=O(N(Q(bM,19),P(bN,13)),N(P(bM,3),Q(bN,29)),N(Q(bM,6),P(bN,26)))local bP=O(N(Q(bN,19),P(bM,13)),N(P(bN,3),Q(bM,29)),Q(bN,6))aQ[cs],aQ[cs-1]=cj(bJ,bK,bO,bP,aQ[cs-14],aQ[cs-15],aQ[cs-32],aQ[cs-33])end;local bH,bM,c1,ck,bR,bV,bX,ct=co[1],co[2],co[3],co[4],co[5],co[6],co[7],co[8]local bI,bN,c2,cl,bS,bW,bY,cu=cp[1],cp[2],cp[3],cp[4],cp[5],cp[6],cp[7],cp[8]for aM=1,80 do local bJ=O(bX,M(bR,O(bV,bX)))local bK=O(bY,M(bS,O(bW,bY)))local bO=O(N(Q(bR,14),P(bS,18)),N(Q(bR,18),P(bS,14)),N(P(bR,23),Q(bS,9)))local bP=O(N(Q(bS,14),P(bR,18)),N(Q(bS,18),P(bR,14)),N(P(bS,23),Q(bR,9)))local cm=bO%2^32+bJ%2^32+ct%2^32+cq[aM]+aQ[2*aM]%2^32;local cw,cx=U(cm),U(bP+bK+cu+cr[aM]+aQ[2*aM-1]+j(cm/2^32))ct,cu,bX,bY,bV,bW=bX,bY,bV,bW,bR,bS;local cm=cw%2^32+ck%2^32;bR,bS=U(cm),U(cx+cl+j(cm/2^32))ck,cl,c1,c2,bM,bN=c1,c2,bM,bN,bH,bI;bO=O(N(Q(bM,28),P(bN,4)),N(P(bM,30),Q(bN,2)),N(P(bM,25),Q(bN,7)))bP=O(N(Q(bN,28),P(bM,4)),N(P(bN,30),Q(bM,2)),N(P(bN,25),Q(bM,7)))bJ=N(M(ck,c1),M(bM,O(ck,c1)))bK=N(M(cl,c2),M(bN,O(cl,c2)))local cm=cw%2^32+bO%2^32+bJ%2^32;bH,bI=U(cm),U(cx+bP+bK+j(cm/2^32))end;co[1],cp[1]=cj(co[1],cp[1],bH,bI,0,0,0,0)co[2],cp[2]=cj(co[2],cp[2],bM,bN,0,0,0,0)co[3],cp[3]=cj(co[3],cp[3],c1,c2,0,0,0,0)co[4],cp[4]=cj(co[4],cp[4],ck,cl,0,0,0,0)co[5],cp[5]=cj(co[5],cp[5],bR,bS,0,0,0,0)co[6],cp[6]=cj(co[6],cp[6],bV,bW,0,0,0,0)co[7],cp[7]=cj(co[7],cp[7],bX,bY,0,0,0,0)co[8],cp[8]=cj(co[8],cp[8],ct,cu,0,0,0,0)end end end;function ae(aN,aO,aP,aK)local aQ,aR=ay,at;for aS=aP,aP+aK-1,64 do for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=N(P(aV,24),P(aU,16),P(E,8),aT)end;local aT,E,aU,aV=aN[1],aN[2],aN[3],aN[4]for aM=1,16,4 do aT,aV,aU,E=aV,aU,E,U(R(O(aV,M(E,O(aU,aV)))+aR[aM]+aQ[aM]+aT,7)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aV,M(E,O(aU,aV)))+aR[aM+1]+aQ[aM+1]+aT,12)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aV,M(E,O(aU,aV)))+aR[aM+2]+aQ[aM+2]+aT,17)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aV,M(E,O(aU,aV)))+aR[aM+3]+aQ[aM+3]+aT,22)+E)end;for aM=17,32,4 do local aY=5*aM-4;aT,aV,aU,E=aV,aU,E,U(R(O(aU,M(aV,O(E,aU)))+aR[aM]+aQ[M(aY,15)+1]+aT,5)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,M(aV,O(E,aU)))+aR[aM+1]+aQ[M(aY+5,15)+1]+aT,9)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,M(aV,O(E,aU)))+aR[aM+2]+aQ[M(aY+10,15)+1]+aT,14)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,M(aV,O(E,aU)))+aR[aM+3]+aQ[M(aY-1,15)+1]+aT,20)+E)end;for aM=33,48,4 do local aY=3*aM+2;aT,aV,aU,E=aV,aU,E,U(R(O(E,aU,aV)+aR[aM]+aQ[M(aY,15)+1]+aT,4)+E)aT,aV,aU,E=aV,aU,E,U(R(O(E,aU,aV)+aR[aM+1]+aQ[M(aY+3,15)+1]+aT,11)+E)aT,aV,aU,E=aV,aU,E,U(R(O(E,aU,aV)+aR[aM+2]+aQ[M(aY+6,15)+1]+aT,16)+E)aT,aV,aU,E=aV,aU,E,U(R(O(E,aU,aV)+aR[aM+3]+aQ[M(aY-7,15)+1]+aT,23)+E)end;for aM=49,64,4 do local aY=aM*7;aT,aV,aU,E=aV,aU,E,U(R(O(aU,N(E,T(aV)))+aR[aM]+aQ[M(aY-7,15)+1]+aT,6)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,N(E,T(aV)))+aR[aM+1]+aQ[M(aY,15)+1]+aT,10)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,N(E,T(aV)))+aR[aM+2]+aQ[M(aY+7,15)+1]+aT,15)+E)aT,aV,aU,E=aV,aU,E,U(R(O(aU,N(E,T(aV)))+aR[aM+3]+aQ[M(aY-2,15)+1]+aT,21)+E)end;aN[1],aN[2],aN[3],aN[4]=U(aT+aN[1]),U(E+aN[2]),U(aU+aN[3]),U(aV+aN[4])end end;function af(aN,aO,aP,aK)local aQ=ay;for aS=aP,aP+aK-1,64 do for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=N(P(aT,24),P(E,16),P(aU,8),aV)end;for aM=17,80 do aQ[aM]=R(O(aQ[aM-3],aQ[aM-8],aQ[aM-14],aQ[aM-16]),1)end;local aT,E,aU,aV,aW=aN[1],aN[2],aN[3],aN[4],aN[5]for aM=1,20,5 do aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(aV,M(E,O(aV,aU)))+aQ[aM]+0x5A827999+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(aV,M(E,O(aV,aU)))+aQ[aM+1]+0x5A827999+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(aV,M(E,O(aV,aU)))+aQ[aM+2]+0x5A827999+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(aV,M(E,O(aV,aU)))+aQ[aM+3]+0x5A827999+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(aV,M(E,O(aV,aU)))+aQ[aM+4]+0x5A827999+aW)end;for aM=21,40,5 do aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM]+0x6ED9EBA1+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+1]+0x6ED9EBA1+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+2]+0x6ED9EBA1+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+3]+0x6ED9EBA1+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+4]+0x6ED9EBA1+aW)end;for aM=41,60,5 do aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(M(aV,O(E,aU)),M(E,aU))+aQ[aM]+0x8F1BBCDC+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(M(aV,O(E,aU)),M(E,aU))+aQ[aM+1]+0x8F1BBCDC+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(M(aV,O(E,aU)),M(E,aU))+aQ[aM+2]+0x8F1BBCDC+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(M(aV,O(E,aU)),M(E,aU))+aQ[aM+3]+0x8F1BBCDC+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(M(aV,O(E,aU)),M(E,aU))+aQ[aM+4]+0x8F1BBCDC+aW)end;for aM=61,80,5 do aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM]+0xCA62C1D6+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+1]+0xCA62C1D6+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+2]+0xCA62C1D6+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+3]+0xCA62C1D6+aW)aW,aV,aU,E,aT=aV,aU,S(E,2),aT,U(R(aT,5)+O(E,aU,aV)+aQ[aM+4]+0xCA62C1D6+aW)end;aN[1],aN[2],aN[3],aN[4],aN[5]=U(aT+aN[1]),U(E+aN[2]),U(aU+aN[3]),U(aV+aN[4]),U(aW+aN[5])end end;do local cy,cz={},{}local function bc(aT,E,aU,aV,bd,be)local aQ=ay;local cA,cB,cC,cD=cy[aT],cy[E],cy[aU],cy[aV]local cE,cF,cG,cH=cz[aT],cz[E],cz[aU],cz[aV]local a7=aQ[2*bd-1]+cA%2^32+cB%2^32;cA=U(a7)cE=U(aQ[2*bd]+cE+cF+j(a7/2^32))cD,cH=O(cH,cE),O(cD,cA)a7=cC%2^32+cD%2^32;cC=U(a7)cG=U(cG+cH+j(a7/2^32))cB,cF=O(cB,cC),O(cF,cG)cB,cF=O(Q(cB,24),P(cF,8)),O(Q(cF,24),P(cB,8))a7=aQ[2*be-1]+cA%2^32+cB%2^32;cA=U(a7)cE=U(aQ[2*be]+cE+cF+j(a7/2^32))cD,cH=O(cD,cA),O(cH,cE)cD,cH=O(Q(cD,16),P(cH,16)),O(Q(cH,16),P(cD,16))a7=cC%2^32+cD%2^32;cC=U(a7)cG=U(cG+cH+j(a7/2^32))cB,cF=O(cB,cC),O(cF,cG)cB,cF=O(P(cB,1),Q(cF,31)),O(P(cF,1),Q(cB,31))cy[aT],cy[E],cy[aU],cy[aV]=cA,cB,cC,cD;cz[aT],cz[E],cz[aU],cz[aV]=cE,cF,cG,cH end;function ai(co,cp,aO,aP,aK,bj,bk,bl)local aQ=ay;local cI,cJ,cK,cL,cM,cN,cO,cP=co[1],co[2],co[3],co[4],co[5],co[6],co[7],co[8]local cQ,cR,cS,cT,cU,cV,cW,cX=cp[1],cp[2],cp[3],cp[4],cp[5],cp[6],cp[7],cp[8]for aS=aP,aP+aK-1,128 do if aO then for aM=1,32 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=aV*2^24+N(P(aU,16),P(E,8),aT)end end;cy[0x0],cy[0x1],cy[0x2],cy[0x3],cy[0x4],cy[0x5],cy[0x6],cy[0x7]=cI,cJ,cK,cL,cM,cN,cO,cP;cy[0x8],cy[0x9],cy[0xA],cy[0xB],cy[0xC],cy[0xD],cy[0xE],cy[0xF]=am[1],am[2],am[3],am[4],am[5],am[6],am[7],am[8]cz[0x0],cz[0x1],cz[0x2],cz[0x3],cz[0x4],cz[0x5],cz[0x6],cz[0x7]=cQ,cR,cS,cT,cU,cV,cW,cX;cz[0x8],cz[0x9],cz[0xA],cz[0xB],cz[0xC],cz[0xD],cz[0xE],cz[0xF]=an[1],an[2],an[3],an[4],an[5],an[6],an[7],an[8]bj=bj+(bk or 128)local cY=bj%2^32;local cZ=j(bj/2^32)cy[0xC]=O(cy[0xC],cY)cz[0xC]=O(cz[0xC],cZ)if bk then cy[0xE]=T(cy[0xE])cz[0xE]=T(cz[0xE])end;if bl then cy[0xF]=T(cy[0xF])cz[0xF]=T(cz[0xF])end;for aM=1,12 do local bu=aF[aM]bc(0,4,8,12,bu[1],bu[2])bc(1,5,9,13,bu[3],bu[4])bc(2,6,10,14,bu[5],bu[6])bc(3,7,11,15,bu[7],bu[8])bc(0,5,10,15,bu[9],bu[10])bc(1,6,11,12,bu[11],bu[12])bc(2,7,8,13,bu[13],bu[14])bc(3,4,9,14,bu[15],bu[16])end;cI=O(cI,cy[0x0],cy[0x8])cJ=O(cJ,cy[0x1],cy[0x9])cK=O(cK,cy[0x2],cy[0xA])cL=O(cL,cy[0x3],cy[0xB])cM=O(cM,cy[0x4],cy[0xC])cN=O(cN,cy[0x5],cy[0xD])cO=O(cO,cy[0x6],cy[0xE])cP=O(cP,cy[0x7],cy[0xF])cQ=O(cQ,cz[0x0],cz[0x8])cR=O(cR,cz[0x1],cz[0x9])cS=O(cS,cz[0x2],cz[0xA])cT=O(cT,cz[0x3],cz[0xB])cU=O(cU,cz[0x4],cz[0xC])cV=O(cV,cz[0x5],cz[0xD])cW=O(cW,cz[0x6],cz[0xE])cX=O(cX,cz[0x7],cz[0xF])end;co[1],co[2],co[3],co[4],co[5],co[6],co[7],co[8]=cI%2^32,cJ%2^32,cK%2^32,cL%2^32,cM%2^32,cN%2^32,cO%2^32,cP%2^32;cp[1],cp[2],cp[3],cp[4],cp[5],cp[6],cp[7],cp[8]=cQ%2^32,cR%2^32,cS%2^32,cT%2^32,cU%2^32,cV%2^32,cW%2^32,cX%2^32;return bj end end end;if L=="FFI"or L=="LJ"then do local aQ=aA;local bb=aB;local function bc(aT,E,aU,aV,bd,be)local bf,bg,bh,bi=bb[aT],bb[E],bb[aU],bb[aV]bf=U(aQ[bd]+bf+bg)bi=S(O(bi,bf),16)bh=U(bh+bi)bg=S(O(bg,bh),12)bf=U(aQ[be]+bf+bg)bi=S(O(bi,bf),8)bh=U(bh+bi)bg=S(O(bg,bh),7)bb[aT],bb[E],bb[aU],bb[aV]=bf,bg,bh,bi end;function ah(aN,aO,aP,aK,bj,bk,bl)local bm,bn,bo,bp,bq,br,bs,bt=U(aN[1]),U(aN[2]),U(aN[3]),U(aN[4]),U(aN[5]),U(aN[6]),U(aN[7]),U(aN[8])for aS=aP,aP+aK-1,64 do if aO then for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=N(P(aV,24),P(aU,16),P(E,8),aT)end end;bb[0x0],bb[0x1],bb[0x2],bb[0x3],bb[0x4],bb[0x5],bb[0x6],bb[0x7]=bm,bn,bo,bp,bq,br,bs,bt;bb[0x8],bb[0x9],bb[0xA],bb[0xB],bb[0xE],bb[0xF]=U(an[1]),U(an[2]),U(an[3]),U(an[4]),U(an[7]),U(an[8])bj=bj+(bk or 64)local c_=bj%2^32;local d0=j(bj/2^32)bb[0xC]=O(an[5],c_)bb[0xD]=O(an[6],d0)if bk then bb[0xE]=T(bb[0xE])end;if bl then bb[0xF]=T(bb[0xF])end;for aM=1,10 do local bu=aF[aM]bc(0,4,8,12,bu[1],bu[2])bc(1,5,9,13,bu[3],bu[4])bc(2,6,10,14,bu[5],bu[6])bc(3,7,11,15,bu[7],bu[8])bc(0,5,10,15,bu[9],bu[10])bc(1,6,11,12,bu[11],bu[12])bc(2,7,8,13,bu[13],bu[14])bc(3,4,9,14,bu[15],bu[16])end;bm=O(bm,bb[0x0],bb[0x8])bn=O(bn,bb[0x1],bb[0x9])bo=O(bo,bb[0x2],bb[0xA])bp=O(bp,bb[0x3],bb[0xB])bq=O(bq,bb[0x4],bb[0xC])br=O(br,bb[0x5],bb[0xD])bs=O(bs,bb[0x6],bb[0xE])bt=O(bt,bb[0x7],bb[0xF])end;aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]=bm,bn,bo,bp,bq,br,bs,bt;return bj end;function aj(aO,aP,aK,d1,d2,d3,d4,d5,d6)d6=d6 or 64;local bm,bn,bo,bp,bq,br,bs,bt=U(d3[1]),U(d3[2]),U(d3[3]),U(d3[4]),U(d3[5]),U(d3[6]),U(d3[7]),U(d3[8])d4=d4 or d3;for aS=aP,aP+aK-1,64 do if aO then for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=N(P(aV,24),P(aU,16),P(E,8),aT)end end;bb[0x0],bb[0x1],bb[0x2],bb[0x3],bb[0x4],bb[0x5],bb[0x6],bb[0x7]=bm,bn,bo,bp,bq,br,bs,bt;bb[0x8],bb[0x9],bb[0xA],bb[0xB]=U(an[1]),U(an[2]),U(an[3]),U(an[4])bb[0xC]=U(d2%2^32)bb[0xD]=j(d2/2^32)bb[0xE],bb[0xF]=d6,d1;for aM=1,7 do bc(0,4,8,12,aG[aM],aG[aM+14])bc(1,5,9,13,aG[aM+1],aG[aM+2])bc(2,6,10,14,aG[aM+16],aG[aM+7])bc(3,7,11,15,aG[aM+15],aG[aM+17])bc(0,5,10,15,aG[aM+21],aG[aM+5])bc(1,6,11,12,aG[aM+3],aG[aM+6])bc(2,7,8,13,aG[aM+4],aG[aM+18])bc(3,4,9,14,aG[aM+19],aG[aM+20])end;if d5 then d4[9]=O(bm,bb[0x8])d4[10]=O(bn,bb[0x9])d4[11]=O(bo,bb[0xA])d4[12]=O(bp,bb[0xB])d4[13]=O(bq,bb[0xC])d4[14]=O(br,bb[0xD])d4[15]=O(bs,bb[0xE])d4[16]=O(bt,bb[0xF])end;bm=O(bb[0x0],bb[0x8])bn=O(bb[0x1],bb[0x9])bo=O(bb[0x2],bb[0xA])bp=O(bb[0x3],bb[0xB])bq=O(bb[0x4],bb[0xC])br=O(bb[0x5],bb[0xD])bs=O(bb[0x6],bb[0xE])bt=O(bb[0x7],bb[0xF])end;d4[1],d4[2],d4[3],d4[4],d4[5],d4[6],d4[7],d4[8]=bm,bn,bo,bp,bq,br,bs,bt end end end;if L=="INT64"then aD=4294967296;aE=4294967296;ax=1;aw,aa,W,ac,ad,ae,af,ag,ah,ai,aj=load[=[-- branch "INT64"
      local md5_next_shift, md5_K, sha2_K_lo, sha2_K_hi, build_keccak_format, sha3_RC_lo, sigma, common_W, sha2_H_lo, sha2_H_hi, perm_blake3 = ...
      local string_format, string_unpack = string.format, string.unpack

      local function HEX64(x)
         return string_format("%016x", x)
      end

      local function XORA5(x, y)
         return x ~ (y or 0xa5a5a5a5a5a5a5a5)
      end

      local function XOR_BYTE(x, y)
         return x ~ y
      end

      local function sha256_feed_64(H, str, offs, size)
         -- offs >= 0, size >= 0, size is multiple of 64
         local W, K = common_W, sha2_K_hi
         local h1, h2, h3, h4, h5, h6, h7, h8 = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
         for pos = offs + 1, offs + size, 64 do
            W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
               string_unpack(">I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4", str, pos)
            for j = 17, 64 do
               local a = W[j-15]
               a = a<<32 | a
               local b = W[j-2]
               b = b<<32 | b
               W[j] = (a>>7 ~ a>>18 ~ a>>35) + (b>>17 ~ b>>19 ~ b>>42) + W[j-7] + W[j-16] & (1<<32)-1
            end
            local a, b, c, d, e, f, g, h = h1, h2, h3, h4, h5, h6, h7, h8
            for j = 1, 64 do
               e = e<<32 | e & (1<<32)-1
               local z = (e>>6 ~ e>>11 ~ e>>25) + (g ~ e & (f ~ g)) + h + K[j] + W[j]
               h = g
               g = f
               f = e
               e = z + d
               d = c
               c = b
               b = a
               a = a<<32 | a & (1<<32)-1
               a = z + ((a ~ c) & d ~ a & c) + (a>>2 ~ a>>13 ~ a>>22)
            end
            h1 = a + h1
            h2 = b + h2
            h3 = c + h3
            h4 = d + h4
            h5 = e + h5
            h6 = f + h6
            h7 = g + h7
            h8 = h + h8
         end
         H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = h1, h2, h3, h4, h5, h6, h7, h8
      end

      local function sha512_feed_128(H, _, str, offs, size)
         -- offs >= 0, size >= 0, size is multiple of 128
         local W, K = common_W, sha2_K_lo
         local h1, h2, h3, h4, h5, h6, h7, h8 = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
         for pos = offs + 1, offs + size, 128 do
            W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
               string_unpack(">i8i8i8i8i8i8i8i8i8i8i8i8i8i8i8i8", str, pos)
            for j = 17, 80 do
               local a = W[j-15]
               local b = W[j-2]
               W[j] = (a >> 1 ~ a >> 7 ~ a >> 8 ~ a << 56 ~ a << 63) + (b >> 6 ~ b >> 19 ~ b >> 61 ~ b << 3 ~ b << 45) + W[j-7] + W[j-16]
            end
            local a, b, c, d, e, f, g, h = h1, h2, h3, h4, h5, h6, h7, h8
            for j = 1, 80 do
               local z = (e >> 14 ~ e >> 18 ~ e >> 41 ~ e << 23 ~ e << 46 ~ e << 50) + (g ~ e & (f ~ g)) + h + K[j] + W[j]
               h = g
               g = f
               f = e
               e = z + d
               d = c
               c = b
               b = a
               a = z + ((a ~ c) & d ~ a & c) + (a >> 28 ~ a >> 34 ~ a >> 39 ~ a << 25 ~ a << 30 ~ a << 36)
            end
            h1 = a + h1
            h2 = b + h2
            h3 = c + h3
            h4 = d + h4
            h5 = e + h5
            h6 = f + h6
            h7 = g + h7
            h8 = h + h8
         end
         H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = h1, h2, h3, h4, h5, h6, h7, h8
      end

      local function md5_feed_64(H, str, offs, size)
         -- offs >= 0, size >= 0, size is multiple of 64
         local W, K, md5_next_shift = common_W, md5_K, md5_next_shift
         local h1, h2, h3, h4 = H[1], H[2], H[3], H[4]
         for pos = offs + 1, offs + size, 64 do
            W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
               string_unpack("<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4", str, pos)
            local a, b, c, d = h1, h2, h3, h4
            local s = 32-7
            for j = 1, 16 do
               local F = (d ~ b & (c ~ d)) + a + K[j] + W[j]
               a = d
               d = c
               c = b
               b = ((F<<32 | F & (1<<32)-1) >> s) + b
               s = md5_next_shift[s]
            end
            s = 32-5
            for j = 17, 32 do
               local F = (c ~ d & (b ~ c)) + a + K[j] + W[(5*j-4 & 15) + 1]
               a = d
               d = c
               c = b
               b = ((F<<32 | F & (1<<32)-1) >> s) + b
               s = md5_next_shift[s]
            end
            s = 32-4
            for j = 33, 48 do
               local F = (b ~ c ~ d) + a + K[j] + W[(3*j+2 & 15) + 1]
               a = d
               d = c
               c = b
               b = ((F<<32 | F & (1<<32)-1) >> s) + b
               s = md5_next_shift[s]
            end
            s = 32-6
            for j = 49, 64 do
               local F = (c ~ (b | ~d)) + a + K[j] + W[(j*7-7 & 15) + 1]
               a = d
               d = c
               c = b
               b = ((F<<32 | F & (1<<32)-1) >> s) + b
               s = md5_next_shift[s]
            end
            h1 = a + h1
            h2 = b + h2
            h3 = c + h3
            h4 = d + h4
         end
         H[1], H[2], H[3], H[4] = h1, h2, h3, h4
      end

      local function sha1_feed_64(H, str, offs, size)
         -- offs >= 0, size >= 0, size is multiple of 64
         local W = common_W
         local h1, h2, h3, h4, h5 = H[1], H[2], H[3], H[4], H[5]
         for pos = offs + 1, offs + size, 64 do
            W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
               string_unpack(">I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4", str, pos)
            for j = 17, 80 do
               local a = W[j-3] ~ W[j-8] ~ W[j-14] ~ W[j-16]
               W[j] = (a<<32 | a) << 1 >> 32
            end
            local a, b, c, d, e = h1, h2, h3, h4, h5
            for j = 1, 20 do
               local z = ((a<<32 | a & (1<<32)-1) >> 27) + (d ~ b & (c ~ d)) + 0x5A827999 + W[j] + e      -- constant = floor(2^30 * sqrt(2))
               e = d
               d = c
               c = (b<<32 | b & (1<<32)-1) >> 2
               b = a
               a = z
            end
            for j = 21, 40 do
               local z = ((a<<32 | a & (1<<32)-1) >> 27) + (b ~ c ~ d) + 0x6ED9EBA1 + W[j] + e            -- 2^30 * sqrt(3)
               e = d
               d = c
               c = (b<<32 | b & (1<<32)-1) >> 2
               b = a
               a = z
            end
            for j = 41, 60 do
               local z = ((a<<32 | a & (1<<32)-1) >> 27) + ((b ~ c) & d ~ b & c) + 0x8F1BBCDC + W[j] + e  -- 2^30 * sqrt(5)
               e = d
               d = c
               c = (b<<32 | b & (1<<32)-1) >> 2
               b = a
               a = z
            end
            for j = 61, 80 do
               local z = ((a<<32 | a & (1<<32)-1) >> 27) + (b ~ c ~ d) + 0xCA62C1D6 + W[j] + e            -- 2^30 * sqrt(10)
               e = d
               d = c
               c = (b<<32 | b & (1<<32)-1) >> 2
               b = a
               a = z
            end
            h1 = a + h1
            h2 = b + h2
            h3 = c + h3
            h4 = d + h4
            h5 = e + h5
         end
         H[1], H[2], H[3], H[4], H[5] = h1, h2, h3, h4, h5
      end

      local keccak_format_i8 = build_keccak_format("i8")

      local function keccak_feed(lanes, _, str, offs, size, block_size_in_bytes)
         -- offs >= 0, size >= 0, size is multiple of block_size_in_bytes, block_size_in_bytes is positive multiple of 8
         local RC = sha3_RC_lo
         local qwords_qty = block_size_in_bytes / 8
         local keccak_format = keccak_format_i8[qwords_qty]
         for pos = offs + 1, offs + size, block_size_in_bytes do
            local qwords_from_message = {string_unpack(keccak_format, str, pos)}
            for j = 1, qwords_qty do
               lanes[j] = lanes[j] ~ qwords_from_message[j]
            end
            local L01, L02, L03, L04, L05, L06, L07, L08, L09, L10, L11, L12, L13, L14, L15, L16, L17, L18, L19, L20, L21, L22, L23, L24, L25 =
               lanes[1], lanes[2], lanes[3], lanes[4], lanes[5], lanes[6], lanes[7], lanes[8], lanes[9], lanes[10], lanes[11], lanes[12], lanes[13],
               lanes[14], lanes[15], lanes[16], lanes[17], lanes[18], lanes[19], lanes[20], lanes[21], lanes[22], lanes[23], lanes[24], lanes[25]
            for round_idx = 1, 24 do
               local C1 = L01 ~ L06 ~ L11 ~ L16 ~ L21
               local C2 = L02 ~ L07 ~ L12 ~ L17 ~ L22
               local C3 = L03 ~ L08 ~ L13 ~ L18 ~ L23
               local C4 = L04 ~ L09 ~ L14 ~ L19 ~ L24
               local C5 = L05 ~ L10 ~ L15 ~ L20 ~ L25
               local D = C1 ~ C3<<1 ~ C3>>63
               local T0 = D ~ L02
               local T1 = D ~ L07
               local T2 = D ~ L12
               local T3 = D ~ L17
               local T4 = D ~ L22
               L02 = T1<<44 ~ T1>>20
               L07 = T3<<45 ~ T3>>19
               L12 = T0<<1 ~ T0>>63
               L17 = T2<<10 ~ T2>>54
               L22 = T4<<2 ~ T4>>62
               D = C2 ~ C4<<1 ~ C4>>63
               T0 = D ~ L03
               T1 = D ~ L08
               T2 = D ~ L13
               T3 = D ~ L18
               T4 = D ~ L23
               L03 = T2<<43 ~ T2>>21
               L08 = T4<<61 ~ T4>>3
               L13 = T1<<6 ~ T1>>58
               L18 = T3<<15 ~ T3>>49
               L23 = T0<<62 ~ T0>>2
               D = C3 ~ C5<<1 ~ C5>>63
               T0 = D ~ L04
               T1 = D ~ L09
               T2 = D ~ L14
               T3 = D ~ L19
               T4 = D ~ L24
               L04 = T3<<21 ~ T3>>43
               L09 = T0<<28 ~ T0>>36
               L14 = T2<<25 ~ T2>>39
               L19 = T4<<56 ~ T4>>8
               L24 = T1<<55 ~ T1>>9
               D = C4 ~ C1<<1 ~ C1>>63
               T0 = D ~ L05
               T1 = D ~ L10
               T2 = D ~ L15
               T3 = D ~ L20
               T4 = D ~ L25
               L05 = T4<<14 ~ T4>>50
               L10 = T1<<20 ~ T1>>44
               L15 = T3<<8 ~ T3>>56
               L20 = T0<<27 ~ T0>>37
               L25 = T2<<39 ~ T2>>25
               D = C5 ~ C2<<1 ~ C2>>63
               T1 = D ~ L06
               T2 = D ~ L11
               T3 = D ~ L16
               T4 = D ~ L21
               L06 = T2<<3 ~ T2>>61
               L11 = T4<<18 ~ T4>>46
               L16 = T1<<36 ~ T1>>28
               L21 = T3<<41 ~ T3>>23
               L01 = D ~ L01
               L01, L02, L03, L04, L05 = L01 ~ ~L02 & L03, L02 ~ ~L03 & L04, L03 ~ ~L04 & L05, L04 ~ ~L05 & L01, L05 ~ ~L01 & L02
               L06, L07, L08, L09, L10 = L09 ~ ~L10 & L06, L10 ~ ~L06 & L07, L06 ~ ~L07 & L08, L07 ~ ~L08 & L09, L08 ~ ~L09 & L10
               L11, L12, L13, L14, L15 = L12 ~ ~L13 & L14, L13 ~ ~L14 & L15, L14 ~ ~L15 & L11, L15 ~ ~L11 & L12, L11 ~ ~L12 & L13
               L16, L17, L18, L19, L20 = L20 ~ ~L16 & L17, L16 ~ ~L17 & L18, L17 ~ ~L18 & L19, L18 ~ ~L19 & L20, L19 ~ ~L20 & L16
               L21, L22, L23, L24, L25 = L23 ~ ~L24 & L25, L24 ~ ~L25 & L21, L25 ~ ~L21 & L22, L21 ~ ~L22 & L23, L22 ~ ~L23 & L24
               L01 = L01 ~ RC[round_idx]
            end
            lanes[1]  = L01
            lanes[2]  = L02
            lanes[3]  = L03
            lanes[4]  = L04
            lanes[5]  = L05
            lanes[6]  = L06
            lanes[7]  = L07
            lanes[8]  = L08
            lanes[9]  = L09
            lanes[10] = L10
            lanes[11] = L11
            lanes[12] = L12
            lanes[13] = L13
            lanes[14] = L14
            lanes[15] = L15
            lanes[16] = L16
            lanes[17] = L17
            lanes[18] = L18
            lanes[19] = L19
            lanes[20] = L20
            lanes[21] = L21
            lanes[22] = L22
            lanes[23] = L23
            lanes[24] = L24
            lanes[25] = L25
         end
      end

      local function blake2s_feed_64(H, str, offs, size, bytes_compressed, last_block_size, is_last_node)
         -- offs >= 0, size >= 0, size is multiple of 64
         local W = common_W
         local h1, h2, h3, h4, h5, h6, h7, h8 = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
         for pos = offs + 1, offs + size, 64 do
            if str then
               W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
                  string_unpack("<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4", str, pos)
            end
            local v0, v1, v2, v3, v4, v5, v6, v7 = h1, h2, h3, h4, h5, h6, h7, h8
            local v8, v9, vA, vB, vC, vD, vE, vF = sha2_H_hi[1], sha2_H_hi[2], sha2_H_hi[3], sha2_H_hi[4], sha2_H_hi[5], sha2_H_hi[6], sha2_H_hi[7], sha2_H_hi[8]
            bytes_compressed = bytes_compressed + (last_block_size or 64)
            vC = vC ~ bytes_compressed        -- t0 = low_4_bytes(bytes_compressed)
            vD = vD ~ bytes_compressed >> 32  -- t1 = high_4_bytes(bytes_compressed)
            if last_block_size then  -- flag f0
               vE = ~vE
            end
            if is_last_node then  -- flag f1
               vF = ~vF
            end
            for j = 1, 10 do
               local row = sigma[j]
               v0 = v0 + v4 + W[row[1]]
               vC = vC ~ v0
               vC = (vC & (1<<32)-1) >> 16 | vC << 16
               v8 = v8 + vC
               v4 = v4 ~ v8
               v4 = (v4 & (1<<32)-1) >> 12 | v4 << 20
               v0 = v0 + v4 + W[row[2]]
               vC = vC ~ v0
               vC = (vC & (1<<32)-1) >> 8 | vC << 24
               v8 = v8 + vC
               v4 = v4 ~ v8
               v4 = (v4 & (1<<32)-1) >> 7 | v4 << 25
               v1 = v1 + v5 + W[row[3]]
               vD = vD ~ v1
               vD = (vD & (1<<32)-1) >> 16 | vD << 16
               v9 = v9 + vD
               v5 = v5 ~ v9
               v5 = (v5 & (1<<32)-1) >> 12 | v5 << 20
               v1 = v1 + v5 + W[row[4]]
               vD = vD ~ v1
               vD = (vD & (1<<32)-1) >> 8 | vD << 24
               v9 = v9 + vD
               v5 = v5 ~ v9
               v5 = (v5 & (1<<32)-1) >> 7 | v5 << 25
               v2 = v2 + v6 + W[row[5]]
               vE = vE ~ v2
               vE = (vE & (1<<32)-1) >> 16 | vE << 16
               vA = vA + vE
               v6 = v6 ~ vA
               v6 = (v6 & (1<<32)-1) >> 12 | v6 << 20
               v2 = v2 + v6 + W[row[6]]
               vE = vE ~ v2
               vE = (vE & (1<<32)-1) >> 8 | vE << 24
               vA = vA + vE
               v6 = v6 ~ vA
               v6 = (v6 & (1<<32)-1) >> 7 | v6 << 25
               v3 = v3 + v7 + W[row[7]]
               vF = vF ~ v3
               vF = (vF & (1<<32)-1) >> 16 | vF << 16
               vB = vB + vF
               v7 = v7 ~ vB
               v7 = (v7 & (1<<32)-1) >> 12 | v7 << 20
               v3 = v3 + v7 + W[row[8]]
               vF = vF ~ v3
               vF = (vF & (1<<32)-1) >> 8 | vF << 24
               vB = vB + vF
               v7 = v7 ~ vB
               v7 = (v7 & (1<<32)-1) >> 7 | v7 << 25
               v0 = v0 + v5 + W[row[9]]
               vF = vF ~ v0
               vF = (vF & (1<<32)-1) >> 16 | vF << 16
               vA = vA + vF
               v5 = v5 ~ vA
               v5 = (v5 & (1<<32)-1) >> 12 | v5 << 20
               v0 = v0 + v5 + W[row[10]]
               vF = vF ~ v0
               vF = (vF & (1<<32)-1) >> 8 | vF << 24
               vA = vA + vF
               v5 = v5 ~ vA
               v5 = (v5 & (1<<32)-1) >> 7 | v5 << 25
               v1 = v1 + v6 + W[row[11]]
               vC = vC ~ v1
               vC = (vC & (1<<32)-1) >> 16 | vC << 16
               vB = vB + vC
               v6 = v6 ~ vB
               v6 = (v6 & (1<<32)-1) >> 12 | v6 << 20
               v1 = v1 + v6 + W[row[12]]
               vC = vC ~ v1
               vC = (vC & (1<<32)-1) >> 8 | vC << 24
               vB = vB + vC
               v6 = v6 ~ vB
               v6 = (v6 & (1<<32)-1) >> 7 | v6 << 25
               v2 = v2 + v7 + W[row[13]]
               vD = vD ~ v2
               vD = (vD & (1<<32)-1) >> 16 | vD << 16
               v8 = v8 + vD
               v7 = v7 ~ v8
               v7 = (v7 & (1<<32)-1) >> 12 | v7 << 20
               v2 = v2 + v7 + W[row[14]]
               vD = vD ~ v2
               vD = (vD & (1<<32)-1) >> 8 | vD << 24
               v8 = v8 + vD
               v7 = v7 ~ v8
               v7 = (v7 & (1<<32)-1) >> 7 | v7 << 25
               v3 = v3 + v4 + W[row[15]]
               vE = vE ~ v3
               vE = (vE & (1<<32)-1) >> 16 | vE << 16
               v9 = v9 + vE
               v4 = v4 ~ v9
               v4 = (v4 & (1<<32)-1) >> 12 | v4 << 20
               v3 = v3 + v4 + W[row[16]]
               vE = vE ~ v3
               vE = (vE & (1<<32)-1) >> 8 | vE << 24
               v9 = v9 + vE
               v4 = v4 ~ v9
               v4 = (v4 & (1<<32)-1) >> 7 | v4 << 25
            end
            h1 = h1 ~ v0 ~ v8
            h2 = h2 ~ v1 ~ v9
            h3 = h3 ~ v2 ~ vA
            h4 = h4 ~ v3 ~ vB
            h5 = h5 ~ v4 ~ vC
            h6 = h6 ~ v5 ~ vD
            h7 = h7 ~ v6 ~ vE
            h8 = h8 ~ v7 ~ vF
         end
         H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = h1, h2, h3, h4, h5, h6, h7, h8
         return bytes_compressed
      end

      local function blake2b_feed_128(H, _, str, offs, size, bytes_compressed, last_block_size, is_last_node)
         -- offs >= 0, size >= 0, size is multiple of 128
         local W = common_W
         local h1, h2, h3, h4, h5, h6, h7, h8 = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
         for pos = offs + 1, offs + size, 128 do
            if str then
               W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
                  string_unpack("<i8i8i8i8i8i8i8i8i8i8i8i8i8i8i8i8", str, pos)
            end
            local v0, v1, v2, v3, v4, v5, v6, v7 = h1, h2, h3, h4, h5, h6, h7, h8
            local v8, v9, vA, vB, vC, vD, vE, vF = sha2_H_lo[1], sha2_H_lo[2], sha2_H_lo[3], sha2_H_lo[4], sha2_H_lo[5], sha2_H_lo[6], sha2_H_lo[7], sha2_H_lo[8]
            bytes_compressed = bytes_compressed + (last_block_size or 128)
            vC = vC ~ bytes_compressed  -- t0 = low_8_bytes(bytes_compressed)
            -- t1 = high_8_bytes(bytes_compressed) = 0,  message length is always below 2^53 bytes
            if last_block_size then  -- flag f0
               vE = ~vE
            end
            if is_last_node then  -- flag f1
               vF = ~vF
            end
            for j = 1, 12 do
               local row = sigma[j]
               v0 = v0 + v4 + W[row[1]]
               vC = vC ~ v0
               vC = vC >> 32 | vC << 32
               v8 = v8 + vC
               v4 = v4 ~ v8
               v4 = v4 >> 24 | v4 << 40
               v0 = v0 + v4 + W[row[2]]
               vC = vC ~ v0
               vC = vC >> 16 | vC << 48
               v8 = v8 + vC
               v4 = v4 ~ v8
               v4 = v4 >> 63 | v4 << 1
               v1 = v1 + v5 + W[row[3]]
               vD = vD ~ v1
               vD = vD >> 32 | vD << 32
               v9 = v9 + vD
               v5 = v5 ~ v9
               v5 = v5 >> 24 | v5 << 40
               v1 = v1 + v5 + W[row[4]]
               vD = vD ~ v1
               vD = vD >> 16 | vD << 48
               v9 = v9 + vD
               v5 = v5 ~ v9
               v5 = v5 >> 63 | v5 << 1
               v2 = v2 + v6 + W[row[5]]
               vE = vE ~ v2
               vE = vE >> 32 | vE << 32
               vA = vA + vE
               v6 = v6 ~ vA
               v6 = v6 >> 24 | v6 << 40
               v2 = v2 + v6 + W[row[6]]
               vE = vE ~ v2
               vE = vE >> 16 | vE << 48
               vA = vA + vE
               v6 = v6 ~ vA
               v6 = v6 >> 63 | v6 << 1
               v3 = v3 + v7 + W[row[7]]
               vF = vF ~ v3
               vF = vF >> 32 | vF << 32
               vB = vB + vF
               v7 = v7 ~ vB
               v7 = v7 >> 24 | v7 << 40
               v3 = v3 + v7 + W[row[8]]
               vF = vF ~ v3
               vF = vF >> 16 | vF << 48
               vB = vB + vF
               v7 = v7 ~ vB
               v7 = v7 >> 63 | v7 << 1
               v0 = v0 + v5 + W[row[9]]
               vF = vF ~ v0
               vF = vF >> 32 | vF << 32
               vA = vA + vF
               v5 = v5 ~ vA
               v5 = v5 >> 24 | v5 << 40
               v0 = v0 + v5 + W[row[10]]
               vF = vF ~ v0
               vF = vF >> 16 | vF << 48
               vA = vA + vF
               v5 = v5 ~ vA
               v5 = v5 >> 63 | v5 << 1
               v1 = v1 + v6 + W[row[11]]
               vC = vC ~ v1
               vC = vC >> 32 | vC << 32
               vB = vB + vC
               v6 = v6 ~ vB
               v6 = v6 >> 24 | v6 << 40
               v1 = v1 + v6 + W[row[12]]
               vC = vC ~ v1
               vC = vC >> 16 | vC << 48
               vB = vB + vC
               v6 = v6 ~ vB
               v6 = v6 >> 63 | v6 << 1
               v2 = v2 + v7 + W[row[13]]
               vD = vD ~ v2
               vD = vD >> 32 | vD << 32
               v8 = v8 + vD
               v7 = v7 ~ v8
               v7 = v7 >> 24 | v7 << 40
               v2 = v2 + v7 + W[row[14]]
               vD = vD ~ v2
               vD = vD >> 16 | vD << 48
               v8 = v8 + vD
               v7 = v7 ~ v8
               v7 = v7 >> 63 | v7 << 1
               v3 = v3 + v4 + W[row[15]]
               vE = vE ~ v3
               vE = vE >> 32 | vE << 32
               v9 = v9 + vE
               v4 = v4 ~ v9
               v4 = v4 >> 24 | v4 << 40
               v3 = v3 + v4 + W[row[16]]
               vE = vE ~ v3
               vE = vE >> 16 | vE << 48
               v9 = v9 + vE
               v4 = v4 ~ v9
               v4 = v4 >> 63 | v4 << 1
            end
            h1 = h1 ~ v0 ~ v8
            h2 = h2 ~ v1 ~ v9
            h3 = h3 ~ v2 ~ vA
            h4 = h4 ~ v3 ~ vB
            h5 = h5 ~ v4 ~ vC
            h6 = h6 ~ v5 ~ vD
            h7 = h7 ~ v6 ~ vE
            h8 = h8 ~ v7 ~ vF
         end
         H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = h1, h2, h3, h4, h5, h6, h7, h8
         return bytes_compressed
      end

      local function blake3_feed_64(str, offs, size, flags, chunk_index, H_in, H_out, wide_output, block_length)
         -- offs >= 0, size >= 0, size is multiple of 64
         block_length = block_length or 64
         local W = common_W
         local h1, h2, h3, h4, h5, h6, h7, h8 = H_in[1], H_in[2], H_in[3], H_in[4], H_in[5], H_in[6], H_in[7], H_in[8]
         H_out = H_out or H_in
         for pos = offs + 1, offs + size, 64 do
            if str then
               W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
                  string_unpack("<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4", str, pos)
            end
            local v0, v1, v2, v3, v4, v5, v6, v7 = h1, h2, h3, h4, h5, h6, h7, h8
            local v8, v9, vA, vB = sha2_H_hi[1], sha2_H_hi[2], sha2_H_hi[3], sha2_H_hi[4]
            local t0 = chunk_index % 2^32         -- t0 = low_4_bytes(chunk_index)
            local t1 = (chunk_index - t0) / 2^32  -- t1 = high_4_bytes(chunk_index)
            local vC, vD, vE, vF = 0|t0, 0|t1, block_length, flags
            for j = 1, 7 do
               v0 = v0 + v4 + W[perm_blake3[j]]
               vC = vC ~ v0
               vC = (vC & (1<<32)-1) >> 16 | vC << 16
               v8 = v8 + vC
               v4 = v4 ~ v8
               v4 = (v4 & (1<<32)-1) >> 12 | v4 << 20
               v0 = v0 + v4 + W[perm_blake3[j + 14]]
               vC = vC ~ v0
               vC = (vC & (1<<32)-1) >> 8 | vC << 24
               v8 = v8 + vC
               v4 = v4 ~ v8
               v4 = (v4 & (1<<32)-1) >> 7 | v4 << 25
               v1 = v1 + v5 + W[perm_blake3[j + 1]]
               vD = vD ~ v1
               vD = (vD & (1<<32)-1) >> 16 | vD << 16
               v9 = v9 + vD
               v5 = v5 ~ v9
               v5 = (v5 & (1<<32)-1) >> 12 | v5 << 20
               v1 = v1 + v5 + W[perm_blake3[j + 2]]
               vD = vD ~ v1
               vD = (vD & (1<<32)-1) >> 8 | vD << 24
               v9 = v9 + vD
               v5 = v5 ~ v9
               v5 = (v5 & (1<<32)-1) >> 7 | v5 << 25
               v2 = v2 + v6 + W[perm_blake3[j + 16]]
               vE = vE ~ v2
               vE = (vE & (1<<32)-1) >> 16 | vE << 16
               vA = vA + vE
               v6 = v6 ~ vA
               v6 = (v6 & (1<<32)-1) >> 12 | v6 << 20
               v2 = v2 + v6 + W[perm_blake3[j + 7]]
               vE = vE ~ v2
               vE = (vE & (1<<32)-1) >> 8 | vE << 24
               vA = vA + vE
               v6 = v6 ~ vA
               v6 = (v6 & (1<<32)-1) >> 7 | v6 << 25
               v3 = v3 + v7 + W[perm_blake3[j + 15]]
               vF = vF ~ v3
               vF = (vF & (1<<32)-1) >> 16 | vF << 16
               vB = vB + vF
               v7 = v7 ~ vB
               v7 = (v7 & (1<<32)-1) >> 12 | v7 << 20
               v3 = v3 + v7 + W[perm_blake3[j + 17]]
               vF = vF ~ v3
               vF = (vF & (1<<32)-1) >> 8 | vF << 24
               vB = vB + vF
               v7 = v7 ~ vB
               v7 = (v7 & (1<<32)-1) >> 7 | v7 << 25
               v0 = v0 + v5 + W[perm_blake3[j + 21]]
               vF = vF ~ v0
               vF = (vF & (1<<32)-1) >> 16 | vF << 16
               vA = vA + vF
               v5 = v5 ~ vA
               v5 = (v5 & (1<<32)-1) >> 12 | v5 << 20
               v0 = v0 + v5 + W[perm_blake3[j + 5]]
               vF = vF ~ v0
               vF = (vF & (1<<32)-1) >> 8 | vF << 24
               vA = vA + vF
               v5 = v5 ~ vA
               v5 = (v5 & (1<<32)-1) >> 7 | v5 << 25
               v1 = v1 + v6 + W[perm_blake3[j + 3]]
               vC = vC ~ v1
               vC = (vC & (1<<32)-1) >> 16 | vC << 16
               vB = vB + vC
               v6 = v6 ~ vB
               v6 = (v6 & (1<<32)-1) >> 12 | v6 << 20
               v1 = v1 + v6 + W[perm_blake3[j + 6]]
               vC = vC ~ v1
               vC = (vC & (1<<32)-1) >> 8 | vC << 24
               vB = vB + vC
               v6 = v6 ~ vB
               v6 = (v6 & (1<<32)-1) >> 7 | v6 << 25
               v2 = v2 + v7 + W[perm_blake3[j + 4]]
               vD = vD ~ v2
               vD = (vD & (1<<32)-1) >> 16 | vD << 16
               v8 = v8 + vD
               v7 = v7 ~ v8
               v7 = (v7 & (1<<32)-1) >> 12 | v7 << 20
               v2 = v2 + v7 + W[perm_blake3[j + 18]]
               vD = vD ~ v2
               vD = (vD & (1<<32)-1) >> 8 | vD << 24
               v8 = v8 + vD
               v7 = v7 ~ v8
               v7 = (v7 & (1<<32)-1) >> 7 | v7 << 25
               v3 = v3 + v4 + W[perm_blake3[j + 19]]
               vE = vE ~ v3
               vE = (vE & (1<<32)-1) >> 16 | vE << 16
               v9 = v9 + vE
               v4 = v4 ~ v9
               v4 = (v4 & (1<<32)-1) >> 12 | v4 << 20
               v3 = v3 + v4 + W[perm_blake3[j + 20]]
               vE = vE ~ v3
               vE = (vE & (1<<32)-1) >> 8 | vE << 24
               v9 = v9 + vE
               v4 = v4 ~ v9
               v4 = (v4 & (1<<32)-1) >> 7 | v4 << 25
            end
            if wide_output then
               H_out[ 9] = h1 ~ v8
               H_out[10] = h2 ~ v9
               H_out[11] = h3 ~ vA
               H_out[12] = h4 ~ vB
               H_out[13] = h5 ~ vC
               H_out[14] = h6 ~ vD
               H_out[15] = h7 ~ vE
               H_out[16] = h8 ~ vF
            end
            h1 = v0 ~ v8
            h2 = v1 ~ v9
            h3 = v2 ~ vA
            h4 = v3 ~ vB
            h5 = v4 ~ vC
            h6 = v5 ~ vD
            h7 = v6 ~ vE
            h8 = v7 ~ vF
         end
         H_out[1], H_out[2], H_out[3], H_out[4], H_out[5], H_out[6], H_out[7], H_out[8] = h1, h2, h3, h4, h5, h6, h7, h8
      end

      return HEX64, XORA5, XOR_BYTE, sha256_feed_64, sha512_feed_128, md5_feed_64, sha1_feed_64, keccak_feed, blake2s_feed_64, blake2b_feed_128, blake3_feed_64
   ]=](av,at,ak,al,aH,ao,aF,ay,am,an,aG)end;if L=="INT32"then aC=2^32;function V(u)return i("%08x",u)end;aa,W,ac,ad,ae,af,ag,ah,ai,aj=load[=[-- branch "INT32"
      local md5_next_shift, md5_K, sha2_K_lo, sha2_K_hi, build_keccak_format, sha3_RC_lo, sha3_RC_hi, sigma, common_W, sha2_H_lo, sha2_H_hi, perm_blake3 = ...
      local string_unpack, floor = string.unpack, math.floor

      local function XORA5(x, y)
         return x ~ (y and (y + 2^31) % 2^32 - 2^31 or 0xA5A5A5A5)
      end

      local function XOR_BYTE(x, y)
         return x ~ y
      end

      local function sha256_feed_64(H, str, offs, size)
         -- offs >= 0, size >= 0, size is multiple of 64
         local W, K = common_W, sha2_K_hi
         local h1, h2, h3, h4, h5, h6, h7, h8 = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
         for pos = offs + 1, offs + size, 64 do
            W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
               string_unpack(">i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4", str, pos)
            for j = 17, 64 do
               local a, b = W[j-15], W[j-2]
               W[j] = (a>>7 ~ a<<25 ~ a<<14 ~ a>>18 ~ a>>3) + (b<<15 ~ b>>17 ~ b<<13 ~ b>>19 ~ b>>10) + W[j-7] + W[j-16]
            end
            local a, b, c, d, e, f, g, h = h1, h2, h3, h4, h5, h6, h7, h8
            for j = 1, 64 do
               local z = (e>>6 ~ e<<26 ~ e>>11 ~ e<<21 ~ e>>25 ~ e<<7) + (g ~ e & (f ~ g)) + h + K[j] + W[j]
               h = g
               g = f
               f = e
               e = z + d
               d = c
               c = b
               b = a
               a = z + ((a ~ c) & d ~ a & c) + (a>>2 ~ a<<30 ~ a>>13 ~ a<<19 ~ a<<10 ~ a>>22)
            end
            h1 = a + h1
            h2 = b + h2
            h3 = c + h3
            h4 = d + h4
            h5 = e + h5
            h6 = f + h6
            h7 = g + h7
            h8 = h + h8
         end
         H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = h1, h2, h3, h4, h5, h6, h7, h8
      end

      local function sha512_feed_128(H_lo, H_hi, str, offs, size)
         -- offs >= 0, size >= 0, size is multiple of 128
         -- W1_hi, W1_lo, W2_hi, W2_lo, ...   Wk_hi = W[2*k-1], Wk_lo = W[2*k]
         local floor, W, K_lo, K_hi = floor, common_W, sha2_K_lo, sha2_K_hi
         local h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo = H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8]
         local h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi = H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8]
         for pos = offs + 1, offs + size, 128 do
            W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16],
               W[17], W[18], W[19], W[20], W[21], W[22], W[23], W[24], W[25], W[26], W[27], W[28], W[29], W[30], W[31], W[32] =
               string_unpack(">i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4", str, pos)
            for jj = 17*2, 80*2, 2 do
               local a_lo, a_hi, b_lo, b_hi = W[jj-30], W[jj-31], W[jj-4], W[jj-5]
               local tmp =
                  (a_lo>>1 ~ a_hi<<31 ~ a_lo>>8 ~ a_hi<<24 ~ a_lo>>7 ~ a_hi<<25) % 2^32
                  + (b_lo>>19 ~ b_hi<<13 ~ b_lo<<3 ~ b_hi>>29 ~ b_lo>>6 ~ b_hi<<26) % 2^32
                  + W[jj-14] % 2^32 + W[jj-32] % 2^32
               W[jj-1] =
                  (a_hi>>1 ~ a_lo<<31 ~ a_hi>>8 ~ a_lo<<24 ~ a_hi>>7)
                  + (b_hi>>19 ~ b_lo<<13 ~ b_hi<<3 ~ b_lo>>29 ~ b_hi>>6)
                  + W[jj-15] + W[jj-33] + floor(tmp / 2^32)
               W[jj] = 0|((tmp + 2^31) % 2^32 - 2^31)
            end
            local a_lo, b_lo, c_lo, d_lo, e_lo, f_lo, g_lo, h_lo = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
            local a_hi, b_hi, c_hi, d_hi, e_hi, f_hi, g_hi, h_hi = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
            for j = 1, 80 do
               local jj = 2*j
               local z_lo = (e_lo>>14 ~ e_hi<<18 ~ e_lo>>18 ~ e_hi<<14 ~ e_lo<<23 ~ e_hi>>9) % 2^32 + (g_lo ~ e_lo & (f_lo ~ g_lo)) % 2^32 + h_lo % 2^32 + K_lo[j] + W[jj] % 2^32
               local z_hi = (e_hi>>14 ~ e_lo<<18 ~ e_hi>>18 ~ e_lo<<14 ~ e_hi<<23 ~ e_lo>>9) + (g_hi ~ e_hi & (f_hi ~ g_hi)) + h_hi + K_hi[j] + W[jj-1] + floor(z_lo / 2^32)
               z_lo = z_lo % 2^32
               h_lo = g_lo;  h_hi = g_hi
               g_lo = f_lo;  g_hi = f_hi
               f_lo = e_lo;  f_hi = e_hi
               e_lo = z_lo + d_lo % 2^32
               e_hi = z_hi + d_hi + floor(e_lo / 2^32)
               e_lo = 0|((e_lo + 2^31) % 2^32 - 2^31)
               d_lo = c_lo;  d_hi = c_hi
               c_lo = b_lo;  c_hi = b_hi
               b_lo = a_lo;  b_hi = a_hi
               z_lo = z_lo + (d_lo & c_lo ~ b_lo & (d_lo ~ c_lo)) % 2^32 + (b_lo>>28 ~ b_hi<<4 ~ b_lo<<30 ~ b_hi>>2 ~ b_lo<<25 ~ b_hi>>7) % 2^32
               a_hi = z_hi + (d_hi & c_hi ~ b_hi & (d_hi ~ c_hi)) + (b_hi>>28 ~ b_lo<<4 ~ b_hi<<30 ~ b_lo>>2 ~ b_hi<<25 ~ b_lo>>7) + floor(z_lo / 2^32)
               a_lo = 0|((z_lo + 2^31) % 2^32 - 2^31)
            end
            a_lo = h1_lo % 2^32 + a_lo % 2^32
            h1_hi = h1_hi + a_hi + floor(a_lo / 2^32)
            h1_lo = 0|((a_lo + 2^31) % 2^32 - 2^31)
            a_lo = h2_lo % 2^32 + b_lo % 2^32
            h2_hi = h2_hi + b_hi + floor(a_lo / 2^32)
            h2_lo = 0|((a_lo + 2^31) % 2^32 - 2^31)
            a_lo = h3_lo % 2^32 + c_lo % 2^32
            h3_hi = h3_hi + c_hi + floor(a_lo / 2^32)
            h3_lo = 0|((a_lo + 2^31) % 2^32 - 2^31)
            a_lo = h4_lo % 2^32 + d_lo % 2^32
            h4_hi = h4_hi + d_hi + floor(a_lo / 2^32)
            h4_lo = 0|((a_lo + 2^31) % 2^32 - 2^31)
            a_lo = h5_lo % 2^32 + e_lo % 2^32
            h5_hi = h5_hi + e_hi + floor(a_lo / 2^32)
            h5_lo = 0|((a_lo + 2^31) % 2^32 - 2^31)
            a_lo = h6_lo % 2^32 + f_lo % 2^32
            h6_hi = h6_hi + f_hi + floor(a_lo / 2^32)
            h6_lo = 0|((a_lo + 2^31) % 2^32 - 2^31)
            a_lo = h7_lo % 2^32 + g_lo % 2^32
            h7_hi = h7_hi + g_hi + floor(a_lo / 2^32)
            h7_lo = 0|((a_lo + 2^31) % 2^32 - 2^31)
            a_lo = h8_lo % 2^32 + h_lo % 2^32
            h8_hi = h8_hi + h_hi + floor(a_lo / 2^32)
            h8_lo = 0|((a_lo + 2^31) % 2^32 - 2^31)
         end
         H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8] = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
         H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8] = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
      end

      local function md5_feed_64(H, str, offs, size)
         -- offs >= 0, size >= 0, size is multiple of 64
         local W, K, md5_next_shift = common_W, md5_K, md5_next_shift
         local h1, h2, h3, h4 = H[1], H[2], H[3], H[4]
         for pos = offs + 1, offs + size, 64 do
            W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
               string_unpack("<i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4", str, pos)
            local a, b, c, d = h1, h2, h3, h4
            local s = 32-7
            for j = 1, 16 do
               local F = (d ~ b & (c ~ d)) + a + K[j] + W[j]
               a = d
               d = c
               c = b
               b = (F << 32-s | F>>s) + b
               s = md5_next_shift[s]
            end
            s = 32-5
            for j = 17, 32 do
               local F = (c ~ d & (b ~ c)) + a + K[j] + W[(5*j-4 & 15) + 1]
               a = d
               d = c
               c = b
               b = (F << 32-s | F>>s) + b
               s = md5_next_shift[s]
            end
            s = 32-4
            for j = 33, 48 do
               local F = (b ~ c ~ d) + a + K[j] + W[(3*j+2 & 15) + 1]
               a = d
               d = c
               c = b
               b = (F << 32-s | F>>s) + b
               s = md5_next_shift[s]
            end
            s = 32-6
            for j = 49, 64 do
               local F = (c ~ (b | ~d)) + a + K[j] + W[(j*7-7 & 15) + 1]
               a = d
               d = c
               c = b
               b = (F << 32-s | F>>s) + b
               s = md5_next_shift[s]
            end
            h1 = a + h1
            h2 = b + h2
            h3 = c + h3
            h4 = d + h4
         end
         H[1], H[2], H[3], H[4] = h1, h2, h3, h4
      end

      local function sha1_feed_64(H, str, offs, size)
         -- offs >= 0, size >= 0, size is multiple of 64
         local W = common_W
         local h1, h2, h3, h4, h5 = H[1], H[2], H[3], H[4], H[5]
         for pos = offs + 1, offs + size, 64 do
            W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
               string_unpack(">i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4", str, pos)
            for j = 17, 80 do
               local a = W[j-3] ~ W[j-8] ~ W[j-14] ~ W[j-16]
               W[j] = a << 1 ~ a >> 31
            end
            local a, b, c, d, e = h1, h2, h3, h4, h5
            for j = 1, 20 do
               local z = (a << 5 ~ a >> 27) + (d ~ b & (c ~ d)) + 0x5A827999 + W[j] + e      -- constant = floor(2^30 * sqrt(2))
               e = d
               d = c
               c = b << 30 ~ b >> 2
               b = a
               a = z
            end
            for j = 21, 40 do
               local z = (a << 5 ~ a >> 27) + (b ~ c ~ d) + 0x6ED9EBA1 + W[j] + e            -- 2^30 * sqrt(3)
               e = d
               d = c
               c = b << 30 ~ b >> 2
               b = a
               a = z
            end
            for j = 41, 60 do
               local z = (a << 5 ~ a >> 27) + ((b ~ c) & d ~ b & c) + 0x8F1BBCDC + W[j] + e  -- 2^30 * sqrt(5)
               e = d
               d = c
               c = b << 30 ~ b >> 2
               b = a
               a = z
            end
            for j = 61, 80 do
               local z = (a << 5 ~ a >> 27) + (b ~ c ~ d) + 0xCA62C1D6 + W[j] + e            -- 2^30 * sqrt(10)
               e = d
               d = c
               c = b << 30 ~ b >> 2
               b = a
               a = z
            end
            h1 = a + h1
            h2 = b + h2
            h3 = c + h3
            h4 = d + h4
            h5 = e + h5
         end
         H[1], H[2], H[3], H[4], H[5] = h1, h2, h3, h4, h5
      end

      local keccak_format_i4i4 = build_keccak_format("i4i4")

      local function keccak_feed(lanes_lo, lanes_hi, str, offs, size, block_size_in_bytes)
         -- offs >= 0, size >= 0, size is multiple of block_size_in_bytes, block_size_in_bytes is positive multiple of 8
         local RC_lo, RC_hi = sha3_RC_lo, sha3_RC_hi
         local qwords_qty = block_size_in_bytes / 8
         local keccak_format = keccak_format_i4i4[qwords_qty]
         for pos = offs + 1, offs + size, block_size_in_bytes do
            local dwords_from_message = {string_unpack(keccak_format, str, pos)}
            for j = 1, qwords_qty do
               lanes_lo[j] = lanes_lo[j] ~ dwords_from_message[2*j-1]
               lanes_hi[j] = lanes_hi[j] ~ dwords_from_message[2*j]
            end
            local L01_lo, L01_hi, L02_lo, L02_hi, L03_lo, L03_hi, L04_lo, L04_hi, L05_lo, L05_hi, L06_lo, L06_hi, L07_lo, L07_hi, L08_lo, L08_hi,
               L09_lo, L09_hi, L10_lo, L10_hi, L11_lo, L11_hi, L12_lo, L12_hi, L13_lo, L13_hi, L14_lo, L14_hi, L15_lo, L15_hi, L16_lo, L16_hi,
               L17_lo, L17_hi, L18_lo, L18_hi, L19_lo, L19_hi, L20_lo, L20_hi, L21_lo, L21_hi, L22_lo, L22_hi, L23_lo, L23_hi, L24_lo, L24_hi, L25_lo, L25_hi =
               lanes_lo[1], lanes_hi[1], lanes_lo[2], lanes_hi[2], lanes_lo[3], lanes_hi[3], lanes_lo[4], lanes_hi[4], lanes_lo[5], lanes_hi[5],
               lanes_lo[6], lanes_hi[6], lanes_lo[7], lanes_hi[7], lanes_lo[8], lanes_hi[8], lanes_lo[9], lanes_hi[9], lanes_lo[10], lanes_hi[10],
               lanes_lo[11], lanes_hi[11], lanes_lo[12], lanes_hi[12], lanes_lo[13], lanes_hi[13], lanes_lo[14], lanes_hi[14], lanes_lo[15], lanes_hi[15],
               lanes_lo[16], lanes_hi[16], lanes_lo[17], lanes_hi[17], lanes_lo[18], lanes_hi[18], lanes_lo[19], lanes_hi[19], lanes_lo[20], lanes_hi[20],
               lanes_lo[21], lanes_hi[21], lanes_lo[22], lanes_hi[22], lanes_lo[23], lanes_hi[23], lanes_lo[24], lanes_hi[24], lanes_lo[25], lanes_hi[25]
            for round_idx = 1, 24 do
               local C1_lo = L01_lo ~ L06_lo ~ L11_lo ~ L16_lo ~ L21_lo
               local C1_hi = L01_hi ~ L06_hi ~ L11_hi ~ L16_hi ~ L21_hi
               local C2_lo = L02_lo ~ L07_lo ~ L12_lo ~ L17_lo ~ L22_lo
               local C2_hi = L02_hi ~ L07_hi ~ L12_hi ~ L17_hi ~ L22_hi
               local C3_lo = L03_lo ~ L08_lo ~ L13_lo ~ L18_lo ~ L23_lo
               local C3_hi = L03_hi ~ L08_hi ~ L13_hi ~ L18_hi ~ L23_hi
               local C4_lo = L04_lo ~ L09_lo ~ L14_lo ~ L19_lo ~ L24_lo
               local C4_hi = L04_hi ~ L09_hi ~ L14_hi ~ L19_hi ~ L24_hi
               local C5_lo = L05_lo ~ L10_lo ~ L15_lo ~ L20_lo ~ L25_lo
               local C5_hi = L05_hi ~ L10_hi ~ L15_hi ~ L20_hi ~ L25_hi
               local D_lo = C1_lo ~ C3_lo<<1 ~ C3_hi>>31
               local D_hi = C1_hi ~ C3_hi<<1 ~ C3_lo>>31
               local T0_lo = D_lo ~ L02_lo
               local T0_hi = D_hi ~ L02_hi
               local T1_lo = D_lo ~ L07_lo
               local T1_hi = D_hi ~ L07_hi
               local T2_lo = D_lo ~ L12_lo
               local T2_hi = D_hi ~ L12_hi
               local T3_lo = D_lo ~ L17_lo
               local T3_hi = D_hi ~ L17_hi
               local T4_lo = D_lo ~ L22_lo
               local T4_hi = D_hi ~ L22_hi
               L02_lo = T1_lo>>20 ~ T1_hi<<12
               L02_hi = T1_hi>>20 ~ T1_lo<<12
               L07_lo = T3_lo>>19 ~ T3_hi<<13
               L07_hi = T3_hi>>19 ~ T3_lo<<13
               L12_lo = T0_lo<<1 ~ T0_hi>>31
               L12_hi = T0_hi<<1 ~ T0_lo>>31
               L17_lo = T2_lo<<10 ~ T2_hi>>22
               L17_hi = T2_hi<<10 ~ T2_lo>>22
               L22_lo = T4_lo<<2 ~ T4_hi>>30
               L22_hi = T4_hi<<2 ~ T4_lo>>30
               D_lo = C2_lo ~ C4_lo<<1 ~ C4_hi>>31
               D_hi = C2_hi ~ C4_hi<<1 ~ C4_lo>>31
               T0_lo = D_lo ~ L03_lo
               T0_hi = D_hi ~ L03_hi
               T1_lo = D_lo ~ L08_lo
               T1_hi = D_hi ~ L08_hi
               T2_lo = D_lo ~ L13_lo
               T2_hi = D_hi ~ L13_hi
               T3_lo = D_lo ~ L18_lo
               T3_hi = D_hi ~ L18_hi
               T4_lo = D_lo ~ L23_lo
               T4_hi = D_hi ~ L23_hi
               L03_lo = T2_lo>>21 ~ T2_hi<<11
               L03_hi = T2_hi>>21 ~ T2_lo<<11
               L08_lo = T4_lo>>3 ~ T4_hi<<29
               L08_hi = T4_hi>>3 ~ T4_lo<<29
               L13_lo = T1_lo<<6 ~ T1_hi>>26
               L13_hi = T1_hi<<6 ~ T1_lo>>26
               L18_lo = T3_lo<<15 ~ T3_hi>>17
               L18_hi = T3_hi<<15 ~ T3_lo>>17
               L23_lo = T0_lo>>2 ~ T0_hi<<30
               L23_hi = T0_hi>>2 ~ T0_lo<<30
               D_lo = C3_lo ~ C5_lo<<1 ~ C5_hi>>31
               D_hi = C3_hi ~ C5_hi<<1 ~ C5_lo>>31
               T0_lo = D_lo ~ L04_lo
               T0_hi = D_hi ~ L04_hi
               T1_lo = D_lo ~ L09_lo
               T1_hi = D_hi ~ L09_hi
               T2_lo = D_lo ~ L14_lo
               T2_hi = D_hi ~ L14_hi
               T3_lo = D_lo ~ L19_lo
               T3_hi = D_hi ~ L19_hi
               T4_lo = D_lo ~ L24_lo
               T4_hi = D_hi ~ L24_hi
               L04_lo = T3_lo<<21 ~ T3_hi>>11
               L04_hi = T3_hi<<21 ~ T3_lo>>11
               L09_lo = T0_lo<<28 ~ T0_hi>>4
               L09_hi = T0_hi<<28 ~ T0_lo>>4
               L14_lo = T2_lo<<25 ~ T2_hi>>7
               L14_hi = T2_hi<<25 ~ T2_lo>>7
               L19_lo = T4_lo>>8 ~ T4_hi<<24
               L19_hi = T4_hi>>8 ~ T4_lo<<24
               L24_lo = T1_lo>>9 ~ T1_hi<<23
               L24_hi = T1_hi>>9 ~ T1_lo<<23
               D_lo = C4_lo ~ C1_lo<<1 ~ C1_hi>>31
               D_hi = C4_hi ~ C1_hi<<1 ~ C1_lo>>31
               T0_lo = D_lo ~ L05_lo
               T0_hi = D_hi ~ L05_hi
               T1_lo = D_lo ~ L10_lo
               T1_hi = D_hi ~ L10_hi
               T2_lo = D_lo ~ L15_lo
               T2_hi = D_hi ~ L15_hi
               T3_lo = D_lo ~ L20_lo
               T3_hi = D_hi ~ L20_hi
               T4_lo = D_lo ~ L25_lo
               T4_hi = D_hi ~ L25_hi
               L05_lo = T4_lo<<14 ~ T4_hi>>18
               L05_hi = T4_hi<<14 ~ T4_lo>>18
               L10_lo = T1_lo<<20 ~ T1_hi>>12
               L10_hi = T1_hi<<20 ~ T1_lo>>12
               L15_lo = T3_lo<<8 ~ T3_hi>>24
               L15_hi = T3_hi<<8 ~ T3_lo>>24
               L20_lo = T0_lo<<27 ~ T0_hi>>5
               L20_hi = T0_hi<<27 ~ T0_lo>>5
               L25_lo = T2_lo>>25 ~ T2_hi<<7
               L25_hi = T2_hi>>25 ~ T2_lo<<7
               D_lo = C5_lo ~ C2_lo<<1 ~ C2_hi>>31
               D_hi = C5_hi ~ C2_hi<<1 ~ C2_lo>>31
               T1_lo = D_lo ~ L06_lo
               T1_hi = D_hi ~ L06_hi
               T2_lo = D_lo ~ L11_lo
               T2_hi = D_hi ~ L11_hi
               T3_lo = D_lo ~ L16_lo
               T3_hi = D_hi ~ L16_hi
               T4_lo = D_lo ~ L21_lo
               T4_hi = D_hi ~ L21_hi
               L06_lo = T2_lo<<3 ~ T2_hi>>29
               L06_hi = T2_hi<<3 ~ T2_lo>>29
               L11_lo = T4_lo<<18 ~ T4_hi>>14
               L11_hi = T4_hi<<18 ~ T4_lo>>14
               L16_lo = T1_lo>>28 ~ T1_hi<<4
               L16_hi = T1_hi>>28 ~ T1_lo<<4
               L21_lo = T3_lo>>23 ~ T3_hi<<9
               L21_hi = T3_hi>>23 ~ T3_lo<<9
               L01_lo = D_lo ~ L01_lo
               L01_hi = D_hi ~ L01_hi
               L01_lo, L02_lo, L03_lo, L04_lo, L05_lo = L01_lo ~ ~L02_lo & L03_lo, L02_lo ~ ~L03_lo & L04_lo, L03_lo ~ ~L04_lo & L05_lo, L04_lo ~ ~L05_lo & L01_lo, L05_lo ~ ~L01_lo & L02_lo
               L01_hi, L02_hi, L03_hi, L04_hi, L05_hi = L01_hi ~ ~L02_hi & L03_hi, L02_hi ~ ~L03_hi & L04_hi, L03_hi ~ ~L04_hi & L05_hi, L04_hi ~ ~L05_hi & L01_hi, L05_hi ~ ~L01_hi & L02_hi
               L06_lo, L07_lo, L08_lo, L09_lo, L10_lo = L09_lo ~ ~L10_lo & L06_lo, L10_lo ~ ~L06_lo & L07_lo, L06_lo ~ ~L07_lo & L08_lo, L07_lo ~ ~L08_lo & L09_lo, L08_lo ~ ~L09_lo & L10_lo
               L06_hi, L07_hi, L08_hi, L09_hi, L10_hi = L09_hi ~ ~L10_hi & L06_hi, L10_hi ~ ~L06_hi & L07_hi, L06_hi ~ ~L07_hi & L08_hi, L07_hi ~ ~L08_hi & L09_hi, L08_hi ~ ~L09_hi & L10_hi
               L11_lo, L12_lo, L13_lo, L14_lo, L15_lo = L12_lo ~ ~L13_lo & L14_lo, L13_lo ~ ~L14_lo & L15_lo, L14_lo ~ ~L15_lo & L11_lo, L15_lo ~ ~L11_lo & L12_lo, L11_lo ~ ~L12_lo & L13_lo
               L11_hi, L12_hi, L13_hi, L14_hi, L15_hi = L12_hi ~ ~L13_hi & L14_hi, L13_hi ~ ~L14_hi & L15_hi, L14_hi ~ ~L15_hi & L11_hi, L15_hi ~ ~L11_hi & L12_hi, L11_hi ~ ~L12_hi & L13_hi
               L16_lo, L17_lo, L18_lo, L19_lo, L20_lo = L20_lo ~ ~L16_lo & L17_lo, L16_lo ~ ~L17_lo & L18_lo, L17_lo ~ ~L18_lo & L19_lo, L18_lo ~ ~L19_lo & L20_lo, L19_lo ~ ~L20_lo & L16_lo
               L16_hi, L17_hi, L18_hi, L19_hi, L20_hi = L20_hi ~ ~L16_hi & L17_hi, L16_hi ~ ~L17_hi & L18_hi, L17_hi ~ ~L18_hi & L19_hi, L18_hi ~ ~L19_hi & L20_hi, L19_hi ~ ~L20_hi & L16_hi
               L21_lo, L22_lo, L23_lo, L24_lo, L25_lo = L23_lo ~ ~L24_lo & L25_lo, L24_lo ~ ~L25_lo & L21_lo, L25_lo ~ ~L21_lo & L22_lo, L21_lo ~ ~L22_lo & L23_lo, L22_lo ~ ~L23_lo & L24_lo
               L21_hi, L22_hi, L23_hi, L24_hi, L25_hi = L23_hi ~ ~L24_hi & L25_hi, L24_hi ~ ~L25_hi & L21_hi, L25_hi ~ ~L21_hi & L22_hi, L21_hi ~ ~L22_hi & L23_hi, L22_hi ~ ~L23_hi & L24_hi
               L01_lo = L01_lo ~ RC_lo[round_idx]
               L01_hi = L01_hi ~ RC_hi[round_idx]
            end
            lanes_lo[1]  = L01_lo;  lanes_hi[1]  = L01_hi
            lanes_lo[2]  = L02_lo;  lanes_hi[2]  = L02_hi
            lanes_lo[3]  = L03_lo;  lanes_hi[3]  = L03_hi
            lanes_lo[4]  = L04_lo;  lanes_hi[4]  = L04_hi
            lanes_lo[5]  = L05_lo;  lanes_hi[5]  = L05_hi
            lanes_lo[6]  = L06_lo;  lanes_hi[6]  = L06_hi
            lanes_lo[7]  = L07_lo;  lanes_hi[7]  = L07_hi
            lanes_lo[8]  = L08_lo;  lanes_hi[8]  = L08_hi
            lanes_lo[9]  = L09_lo;  lanes_hi[9]  = L09_hi
            lanes_lo[10] = L10_lo;  lanes_hi[10] = L10_hi
            lanes_lo[11] = L11_lo;  lanes_hi[11] = L11_hi
            lanes_lo[12] = L12_lo;  lanes_hi[12] = L12_hi
            lanes_lo[13] = L13_lo;  lanes_hi[13] = L13_hi
            lanes_lo[14] = L14_lo;  lanes_hi[14] = L14_hi
            lanes_lo[15] = L15_lo;  lanes_hi[15] = L15_hi
            lanes_lo[16] = L16_lo;  lanes_hi[16] = L16_hi
            lanes_lo[17] = L17_lo;  lanes_hi[17] = L17_hi
            lanes_lo[18] = L18_lo;  lanes_hi[18] = L18_hi
            lanes_lo[19] = L19_lo;  lanes_hi[19] = L19_hi
            lanes_lo[20] = L20_lo;  lanes_hi[20] = L20_hi
            lanes_lo[21] = L21_lo;  lanes_hi[21] = L21_hi
            lanes_lo[22] = L22_lo;  lanes_hi[22] = L22_hi
            lanes_lo[23] = L23_lo;  lanes_hi[23] = L23_hi
            lanes_lo[24] = L24_lo;  lanes_hi[24] = L24_hi
            lanes_lo[25] = L25_lo;  lanes_hi[25] = L25_hi
         end
      end

      local function blake2s_feed_64(H, str, offs, size, bytes_compressed, last_block_size, is_last_node)
         -- offs >= 0, size >= 0, size is multiple of 64
         local W = common_W
         local h1, h2, h3, h4, h5, h6, h7, h8 = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
         for pos = offs + 1, offs + size, 64 do
            if str then
               W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
                  string_unpack("<i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4", str, pos)
            end
            local v0, v1, v2, v3, v4, v5, v6, v7 = h1, h2, h3, h4, h5, h6, h7, h8
            local v8, v9, vA, vB, vC, vD, vE, vF = sha2_H_hi[1], sha2_H_hi[2], sha2_H_hi[3], sha2_H_hi[4], sha2_H_hi[5], sha2_H_hi[6], sha2_H_hi[7], sha2_H_hi[8]
            bytes_compressed = bytes_compressed + (last_block_size or 64)
            local t0 = bytes_compressed % 2^32
            local t1 = (bytes_compressed - t0) / 2^32
            t0 = (t0 + 2^31) % 2^32 - 2^31  -- convert to int32 range (-2^31)..(2^31-1) to avoid "number has no integer representation" error while XORing
            vC = vC ~ t0  -- t0 = low_4_bytes(bytes_compressed)
            vD = vD ~ t1  -- t1 = high_4_bytes(bytes_compressed)
            if last_block_size then  -- flag f0
               vE = ~vE
            end
            if is_last_node then  -- flag f1
               vF = ~vF
            end
            for j = 1, 10 do
               local row = sigma[j]
               v0 = v0 + v4 + W[row[1]]
               vC = vC ~ v0
               vC = vC >> 16 | vC << 16
               v8 = v8 + vC
               v4 = v4 ~ v8
               v4 = v4 >> 12 | v4 << 20
               v0 = v0 + v4 + W[row[2]]
               vC = vC ~ v0
               vC = vC >> 8 | vC << 24
               v8 = v8 + vC
               v4 = v4 ~ v8
               v4 = v4 >> 7 | v4 << 25
               v1 = v1 + v5 + W[row[3]]
               vD = vD ~ v1
               vD = vD >> 16 | vD << 16
               v9 = v9 + vD
               v5 = v5 ~ v9
               v5 = v5 >> 12 | v5 << 20
               v1 = v1 + v5 + W[row[4]]
               vD = vD ~ v1
               vD = vD >> 8 | vD << 24
               v9 = v9 + vD
               v5 = v5 ~ v9
               v5 = v5 >> 7 | v5 << 25
               v2 = v2 + v6 + W[row[5]]
               vE = vE ~ v2
               vE = vE >> 16 | vE << 16
               vA = vA + vE
               v6 = v6 ~ vA
               v6 = v6 >> 12 | v6 << 20
               v2 = v2 + v6 + W[row[6]]
               vE = vE ~ v2
               vE = vE >> 8 | vE << 24
               vA = vA + vE
               v6 = v6 ~ vA
               v6 = v6 >> 7 | v6 << 25
               v3 = v3 + v7 + W[row[7]]
               vF = vF ~ v3
               vF = vF >> 16 | vF << 16
               vB = vB + vF
               v7 = v7 ~ vB
               v7 = v7 >> 12 | v7 << 20
               v3 = v3 + v7 + W[row[8]]
               vF = vF ~ v3
               vF = vF >> 8 | vF << 24
               vB = vB + vF
               v7 = v7 ~ vB
               v7 = v7 >> 7 | v7 << 25
               v0 = v0 + v5 + W[row[9]]
               vF = vF ~ v0
               vF = vF >> 16 | vF << 16
               vA = vA + vF
               v5 = v5 ~ vA
               v5 = v5 >> 12 | v5 << 20
               v0 = v0 + v5 + W[row[10]]
               vF = vF ~ v0
               vF = vF >> 8 | vF << 24
               vA = vA + vF
               v5 = v5 ~ vA
               v5 = v5 >> 7 | v5 << 25
               v1 = v1 + v6 + W[row[11]]
               vC = vC ~ v1
               vC = vC >> 16 | vC << 16
               vB = vB + vC
               v6 = v6 ~ vB
               v6 = v6 >> 12 | v6 << 20
               v1 = v1 + v6 + W[row[12]]
               vC = vC ~ v1
               vC = vC >> 8 | vC << 24
               vB = vB + vC
               v6 = v6 ~ vB
               v6 = v6 >> 7 | v6 << 25
               v2 = v2 + v7 + W[row[13]]
               vD = vD ~ v2
               vD = vD >> 16 | vD << 16
               v8 = v8 + vD
               v7 = v7 ~ v8
               v7 = v7 >> 12 | v7 << 20
               v2 = v2 + v7 + W[row[14]]
               vD = vD ~ v2
               vD = vD >> 8 | vD << 24
               v8 = v8 + vD
               v7 = v7 ~ v8
               v7 = v7 >> 7 | v7 << 25
               v3 = v3 + v4 + W[row[15]]
               vE = vE ~ v3
               vE = vE >> 16 | vE << 16
               v9 = v9 + vE
               v4 = v4 ~ v9
               v4 = v4 >> 12 | v4 << 20
               v3 = v3 + v4 + W[row[16]]
               vE = vE ~ v3
               vE = vE >> 8 | vE << 24
               v9 = v9 + vE
               v4 = v4 ~ v9
               v4 = v4 >> 7 | v4 << 25
            end
            h1 = h1 ~ v0 ~ v8
            h2 = h2 ~ v1 ~ v9
            h3 = h3 ~ v2 ~ vA
            h4 = h4 ~ v3 ~ vB
            h5 = h5 ~ v4 ~ vC
            h6 = h6 ~ v5 ~ vD
            h7 = h7 ~ v6 ~ vE
            h8 = h8 ~ v7 ~ vF
         end
         H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = h1, h2, h3, h4, h5, h6, h7, h8
         return bytes_compressed
      end

      local function blake2b_feed_128(H_lo, H_hi, str, offs, size, bytes_compressed, last_block_size, is_last_node)
         -- offs >= 0, size >= 0, size is multiple of 128
         local W = common_W
         local h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo = H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8]
         local h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi = H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8]
         for pos = offs + 1, offs + size, 128 do
            if str then
               W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16],
               W[17], W[18], W[19], W[20], W[21], W[22], W[23], W[24], W[25], W[26], W[27], W[28], W[29], W[30], W[31], W[32] =
                  string_unpack("<i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4", str, pos)
            end
            local v0_lo, v1_lo, v2_lo, v3_lo, v4_lo, v5_lo, v6_lo, v7_lo = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
            local v0_hi, v1_hi, v2_hi, v3_hi, v4_hi, v5_hi, v6_hi, v7_hi = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
            local v8_lo, v9_lo, vA_lo, vB_lo, vC_lo, vD_lo, vE_lo, vF_lo = sha2_H_lo[1], sha2_H_lo[2], sha2_H_lo[3], sha2_H_lo[4], sha2_H_lo[5], sha2_H_lo[6], sha2_H_lo[7], sha2_H_lo[8]
            local v8_hi, v9_hi, vA_hi, vB_hi, vC_hi, vD_hi, vE_hi, vF_hi = sha2_H_hi[1], sha2_H_hi[2], sha2_H_hi[3], sha2_H_hi[4], sha2_H_hi[5], sha2_H_hi[6], sha2_H_hi[7], sha2_H_hi[8]
            bytes_compressed = bytes_compressed + (last_block_size or 128)
            local t0_lo = bytes_compressed % 2^32
            local t0_hi = (bytes_compressed - t0_lo) / 2^32
            t0_lo = (t0_lo + 2^31) % 2^32 - 2^31  -- convert to int32 range (-2^31)..(2^31-1) to avoid "number has no integer representation" error while XORing
            vC_lo = vC_lo ~ t0_lo  -- t0 = low_8_bytes(bytes_compressed)
            vC_hi = vC_hi ~ t0_hi
            -- t1 = high_8_bytes(bytes_compressed) = 0,  message length is always below 2^53 bytes
            if last_block_size then  -- flag f0
               vE_lo = ~vE_lo
               vE_hi = ~vE_hi
            end
            if is_last_node then  -- flag f1
               vF_lo = ~vF_lo
               vF_hi = ~vF_hi
            end
            for j = 1, 12 do
               local row = sigma[j]
               local k = row[1] * 2
               v0_lo = v0_lo % 2^32 + v4_lo % 2^32 + W[k-1] % 2^32
               v0_hi = v0_hi + v4_hi + floor(v0_lo / 2^32) + W[k]
               v0_lo = 0|((v0_lo + 2^31) % 2^32 - 2^31)
               vC_lo, vC_hi = vC_hi ~ v0_hi, vC_lo ~ v0_lo
               v8_lo = v8_lo % 2^32 + vC_lo % 2^32
               v8_hi = v8_hi + vC_hi + floor(v8_lo / 2^32)
               v8_lo = 0|((v8_lo + 2^31) % 2^32 - 2^31)
               v4_lo, v4_hi = v4_lo ~ v8_lo, v4_hi ~ v8_hi
               v4_lo, v4_hi = v4_lo >> 24 | v4_hi << 8, v4_hi >> 24 | v4_lo << 8
               k = row[2] * 2
               v0_lo = v0_lo % 2^32 + v4_lo % 2^32 + W[k-1] % 2^32
               v0_hi = v0_hi + v4_hi + floor(v0_lo / 2^32) + W[k]
               v0_lo = 0|((v0_lo + 2^31) % 2^32 - 2^31)
               vC_lo, vC_hi = vC_lo ~ v0_lo, vC_hi ~ v0_hi
               vC_lo, vC_hi = vC_lo >> 16 | vC_hi << 16, vC_hi >> 16 | vC_lo << 16
               v8_lo = v8_lo % 2^32 + vC_lo % 2^32
               v8_hi = v8_hi + vC_hi + floor(v8_lo / 2^32)
               v8_lo = 0|((v8_lo + 2^31) % 2^32 - 2^31)
               v4_lo, v4_hi = v4_lo ~ v8_lo, v4_hi ~ v8_hi
               v4_lo, v4_hi = v4_lo << 1 | v4_hi >> 31, v4_hi << 1 | v4_lo >> 31
               k = row[3] * 2
               v1_lo = v1_lo % 2^32 + v5_lo % 2^32 + W[k-1] % 2^32
               v1_hi = v1_hi + v5_hi + floor(v1_lo / 2^32) + W[k]
               v1_lo = 0|((v1_lo + 2^31) % 2^32 - 2^31)
               vD_lo, vD_hi = vD_hi ~ v1_hi, vD_lo ~ v1_lo
               v9_lo = v9_lo % 2^32 + vD_lo % 2^32
               v9_hi = v9_hi + vD_hi + floor(v9_lo / 2^32)
               v9_lo = 0|((v9_lo + 2^31) % 2^32 - 2^31)
               v5_lo, v5_hi = v5_lo ~ v9_lo, v5_hi ~ v9_hi
               v5_lo, v5_hi = v5_lo >> 24 | v5_hi << 8, v5_hi >> 24 | v5_lo << 8
               k = row[4] * 2
               v1_lo = v1_lo % 2^32 + v5_lo % 2^32 + W[k-1] % 2^32
               v1_hi = v1_hi + v5_hi + floor(v1_lo / 2^32) + W[k]
               v1_lo = 0|((v1_lo + 2^31) % 2^32 - 2^31)
               vD_lo, vD_hi = vD_lo ~ v1_lo, vD_hi ~ v1_hi
               vD_lo, vD_hi = vD_lo >> 16 | vD_hi << 16, vD_hi >> 16 | vD_lo << 16
               v9_lo = v9_lo % 2^32 + vD_lo % 2^32
               v9_hi = v9_hi + vD_hi + floor(v9_lo / 2^32)
               v9_lo = 0|((v9_lo + 2^31) % 2^32 - 2^31)
               v5_lo, v5_hi = v5_lo ~ v9_lo, v5_hi ~ v9_hi
               v5_lo, v5_hi = v5_lo << 1 | v5_hi >> 31, v5_hi << 1 | v5_lo >> 31
               k = row[5] * 2
               v2_lo = v2_lo % 2^32 + v6_lo % 2^32 + W[k-1] % 2^32
               v2_hi = v2_hi + v6_hi + floor(v2_lo / 2^32) + W[k]
               v2_lo = 0|((v2_lo + 2^31) % 2^32 - 2^31)
               vE_lo, vE_hi = vE_hi ~ v2_hi, vE_lo ~ v2_lo
               vA_lo = vA_lo % 2^32 + vE_lo % 2^32
               vA_hi = vA_hi + vE_hi + floor(vA_lo / 2^32)
               vA_lo = 0|((vA_lo + 2^31) % 2^32 - 2^31)
               v6_lo, v6_hi = v6_lo ~ vA_lo, v6_hi ~ vA_hi
               v6_lo, v6_hi = v6_lo >> 24 | v6_hi << 8, v6_hi >> 24 | v6_lo << 8
               k = row[6] * 2
               v2_lo = v2_lo % 2^32 + v6_lo % 2^32 + W[k-1] % 2^32
               v2_hi = v2_hi + v6_hi + floor(v2_lo / 2^32) + W[k]
               v2_lo = 0|((v2_lo + 2^31) % 2^32 - 2^31)
               vE_lo, vE_hi = vE_lo ~ v2_lo, vE_hi ~ v2_hi
               vE_lo, vE_hi = vE_lo >> 16 | vE_hi << 16, vE_hi >> 16 | vE_lo << 16
               vA_lo = vA_lo % 2^32 + vE_lo % 2^32
               vA_hi = vA_hi + vE_hi + floor(vA_lo / 2^32)
               vA_lo = 0|((vA_lo + 2^31) % 2^32 - 2^31)
               v6_lo, v6_hi = v6_lo ~ vA_lo, v6_hi ~ vA_hi
               v6_lo, v6_hi = v6_lo << 1 | v6_hi >> 31, v6_hi << 1 | v6_lo >> 31
               k = row[7] * 2
               v3_lo = v3_lo % 2^32 + v7_lo % 2^32 + W[k-1] % 2^32
               v3_hi = v3_hi + v7_hi + floor(v3_lo / 2^32) + W[k]
               v3_lo = 0|((v3_lo + 2^31) % 2^32 - 2^31)
               vF_lo, vF_hi = vF_hi ~ v3_hi, vF_lo ~ v3_lo
               vB_lo = vB_lo % 2^32 + vF_lo % 2^32
               vB_hi = vB_hi + vF_hi + floor(vB_lo / 2^32)
               vB_lo = 0|((vB_lo + 2^31) % 2^32 - 2^31)
               v7_lo, v7_hi = v7_lo ~ vB_lo, v7_hi ~ vB_hi
               v7_lo, v7_hi = v7_lo >> 24 | v7_hi << 8, v7_hi >> 24 | v7_lo << 8
               k = row[8] * 2
               v3_lo = v3_lo % 2^32 + v7_lo % 2^32 + W[k-1] % 2^32
               v3_hi = v3_hi + v7_hi + floor(v3_lo / 2^32) + W[k]
               v3_lo = 0|((v3_lo + 2^31) % 2^32 - 2^31)
               vF_lo, vF_hi = vF_lo ~ v3_lo, vF_hi ~ v3_hi
               vF_lo, vF_hi = vF_lo >> 16 | vF_hi << 16, vF_hi >> 16 | vF_lo << 16
               vB_lo = vB_lo % 2^32 + vF_lo % 2^32
               vB_hi = vB_hi + vF_hi + floor(vB_lo / 2^32)
               vB_lo = 0|((vB_lo + 2^31) % 2^32 - 2^31)
               v7_lo, v7_hi = v7_lo ~ vB_lo, v7_hi ~ vB_hi
               v7_lo, v7_hi = v7_lo << 1 | v7_hi >> 31, v7_hi << 1 | v7_lo >> 31
               k = row[9] * 2
               v0_lo = v0_lo % 2^32 + v5_lo % 2^32 + W[k-1] % 2^32
               v0_hi = v0_hi + v5_hi + floor(v0_lo / 2^32) + W[k]
               v0_lo = 0|((v0_lo + 2^31) % 2^32 - 2^31)
               vF_lo, vF_hi = vF_hi ~ v0_hi, vF_lo ~ v0_lo
               vA_lo = vA_lo % 2^32 + vF_lo % 2^32
               vA_hi = vA_hi + vF_hi + floor(vA_lo / 2^32)
               vA_lo = 0|((vA_lo + 2^31) % 2^32 - 2^31)
               v5_lo, v5_hi = v5_lo ~ vA_lo, v5_hi ~ vA_hi
               v5_lo, v5_hi = v5_lo >> 24 | v5_hi << 8, v5_hi >> 24 | v5_lo << 8
               k = row[10] * 2
               v0_lo = v0_lo % 2^32 + v5_lo % 2^32 + W[k-1] % 2^32
               v0_hi = v0_hi + v5_hi + floor(v0_lo / 2^32) + W[k]
               v0_lo = 0|((v0_lo + 2^31) % 2^32 - 2^31)
               vF_lo, vF_hi = vF_lo ~ v0_lo, vF_hi ~ v0_hi
               vF_lo, vF_hi = vF_lo >> 16 | vF_hi << 16, vF_hi >> 16 | vF_lo << 16
               vA_lo = vA_lo % 2^32 + vF_lo % 2^32
               vA_hi = vA_hi + vF_hi + floor(vA_lo / 2^32)
               vA_lo = 0|((vA_lo + 2^31) % 2^32 - 2^31)
               v5_lo, v5_hi = v5_lo ~ vA_lo, v5_hi ~ vA_hi
               v5_lo, v5_hi = v5_lo << 1 | v5_hi >> 31, v5_hi << 1 | v5_lo >> 31
               k = row[11] * 2
               v1_lo = v1_lo % 2^32 + v6_lo % 2^32 + W[k-1] % 2^32
               v1_hi = v1_hi + v6_hi + floor(v1_lo / 2^32) + W[k]
               v1_lo = 0|((v1_lo + 2^31) % 2^32 - 2^31)
               vC_lo, vC_hi = vC_hi ~ v1_hi, vC_lo ~ v1_lo
               vB_lo = vB_lo % 2^32 + vC_lo % 2^32
               vB_hi = vB_hi + vC_hi + floor(vB_lo / 2^32)
               vB_lo = 0|((vB_lo + 2^31) % 2^32 - 2^31)
               v6_lo, v6_hi = v6_lo ~ vB_lo, v6_hi ~ vB_hi
               v6_lo, v6_hi = v6_lo >> 24 | v6_hi << 8, v6_hi >> 24 | v6_lo << 8
               k = row[12] * 2
               v1_lo = v1_lo % 2^32 + v6_lo % 2^32 + W[k-1] % 2^32
               v1_hi = v1_hi + v6_hi + floor(v1_lo / 2^32) + W[k]
               v1_lo = 0|((v1_lo + 2^31) % 2^32 - 2^31)
               vC_lo, vC_hi = vC_lo ~ v1_lo, vC_hi ~ v1_hi
               vC_lo, vC_hi = vC_lo >> 16 | vC_hi << 16, vC_hi >> 16 | vC_lo << 16
               vB_lo = vB_lo % 2^32 + vC_lo % 2^32
               vB_hi = vB_hi + vC_hi + floor(vB_lo / 2^32)
               vB_lo = 0|((vB_lo + 2^31) % 2^32 - 2^31)
               v6_lo, v6_hi = v6_lo ~ vB_lo, v6_hi ~ vB_hi
               v6_lo, v6_hi = v6_lo << 1 | v6_hi >> 31, v6_hi << 1 | v6_lo >> 31
               k = row[13] * 2
               v2_lo = v2_lo % 2^32 + v7_lo % 2^32 + W[k-1] % 2^32
               v2_hi = v2_hi + v7_hi + floor(v2_lo / 2^32) + W[k]
               v2_lo = 0|((v2_lo + 2^31) % 2^32 - 2^31)
               vD_lo, vD_hi = vD_hi ~ v2_hi, vD_lo ~ v2_lo
               v8_lo = v8_lo % 2^32 + vD_lo % 2^32
               v8_hi = v8_hi + vD_hi + floor(v8_lo / 2^32)
               v8_lo = 0|((v8_lo + 2^31) % 2^32 - 2^31)
               v7_lo, v7_hi = v7_lo ~ v8_lo, v7_hi ~ v8_hi
               v7_lo, v7_hi = v7_lo >> 24 | v7_hi << 8, v7_hi >> 24 | v7_lo << 8
               k = row[14] * 2
               v2_lo = v2_lo % 2^32 + v7_lo % 2^32 + W[k-1] % 2^32
               v2_hi = v2_hi + v7_hi + floor(v2_lo / 2^32) + W[k]
               v2_lo = 0|((v2_lo + 2^31) % 2^32 - 2^31)
               vD_lo, vD_hi = vD_lo ~ v2_lo, vD_hi ~ v2_hi
               vD_lo, vD_hi = vD_lo >> 16 | vD_hi << 16, vD_hi >> 16 | vD_lo << 16
               v8_lo = v8_lo % 2^32 + vD_lo % 2^32
               v8_hi = v8_hi + vD_hi + floor(v8_lo / 2^32)
               v8_lo = 0|((v8_lo + 2^31) % 2^32 - 2^31)
               v7_lo, v7_hi = v7_lo ~ v8_lo, v7_hi ~ v8_hi
               v7_lo, v7_hi = v7_lo << 1 | v7_hi >> 31, v7_hi << 1 | v7_lo >> 31
               k = row[15] * 2
               v3_lo = v3_lo % 2^32 + v4_lo % 2^32 + W[k-1] % 2^32
               v3_hi = v3_hi + v4_hi + floor(v3_lo / 2^32) + W[k]
               v3_lo = 0|((v3_lo + 2^31) % 2^32 - 2^31)
               vE_lo, vE_hi = vE_hi ~ v3_hi, vE_lo ~ v3_lo
               v9_lo = v9_lo % 2^32 + vE_lo % 2^32
               v9_hi = v9_hi + vE_hi + floor(v9_lo / 2^32)
               v9_lo = 0|((v9_lo + 2^31) % 2^32 - 2^31)
               v4_lo, v4_hi = v4_lo ~ v9_lo, v4_hi ~ v9_hi
               v4_lo, v4_hi = v4_lo >> 24 | v4_hi << 8, v4_hi >> 24 | v4_lo << 8
               k = row[16] * 2
               v3_lo = v3_lo % 2^32 + v4_lo % 2^32 + W[k-1] % 2^32
               v3_hi = v3_hi + v4_hi + floor(v3_lo / 2^32) + W[k]
               v3_lo = 0|((v3_lo + 2^31) % 2^32 - 2^31)
               vE_lo, vE_hi = vE_lo ~ v3_lo, vE_hi ~ v3_hi
               vE_lo, vE_hi = vE_lo >> 16 | vE_hi << 16, vE_hi >> 16 | vE_lo << 16
               v9_lo = v9_lo % 2^32 + vE_lo % 2^32
               v9_hi = v9_hi + vE_hi + floor(v9_lo / 2^32)
               v9_lo = 0|((v9_lo + 2^31) % 2^32 - 2^31)
               v4_lo, v4_hi = v4_lo ~ v9_lo, v4_hi ~ v9_hi
               v4_lo, v4_hi = v4_lo << 1 | v4_hi >> 31, v4_hi << 1 | v4_lo >> 31
            end
            h1_lo = h1_lo ~ v0_lo ~ v8_lo
            h2_lo = h2_lo ~ v1_lo ~ v9_lo
            h3_lo = h3_lo ~ v2_lo ~ vA_lo
            h4_lo = h4_lo ~ v3_lo ~ vB_lo
            h5_lo = h5_lo ~ v4_lo ~ vC_lo
            h6_lo = h6_lo ~ v5_lo ~ vD_lo
            h7_lo = h7_lo ~ v6_lo ~ vE_lo
            h8_lo = h8_lo ~ v7_lo ~ vF_lo
            h1_hi = h1_hi ~ v0_hi ~ v8_hi
            h2_hi = h2_hi ~ v1_hi ~ v9_hi
            h3_hi = h3_hi ~ v2_hi ~ vA_hi
            h4_hi = h4_hi ~ v3_hi ~ vB_hi
            h5_hi = h5_hi ~ v4_hi ~ vC_hi
            h6_hi = h6_hi ~ v5_hi ~ vD_hi
            h7_hi = h7_hi ~ v6_hi ~ vE_hi
            h8_hi = h8_hi ~ v7_hi ~ vF_hi
         end
         H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8] = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
         H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8] = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
         return bytes_compressed
      end

      local function blake3_feed_64(str, offs, size, flags, chunk_index, H_in, H_out, wide_output, block_length)
         -- offs >= 0, size >= 0, size is multiple of 64
         block_length = block_length or 64
         local W = common_W
         local h1, h2, h3, h4, h5, h6, h7, h8 = H_in[1], H_in[2], H_in[3], H_in[4], H_in[5], H_in[6], H_in[7], H_in[8]
         H_out = H_out or H_in
         for pos = offs + 1, offs + size, 64 do
            if str then
               W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
                  string_unpack("<i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4", str, pos)
            end
            local v0, v1, v2, v3, v4, v5, v6, v7 = h1, h2, h3, h4, h5, h6, h7, h8
            local v8, v9, vA, vB = sha2_H_hi[1], sha2_H_hi[2], sha2_H_hi[3], sha2_H_hi[4]
            local t0 = chunk_index % 2^32         -- t0 = low_4_bytes(chunk_index)
            local t1 = (chunk_index - t0) / 2^32  -- t1 = high_4_bytes(chunk_index)
            t0 = (t0 + 2^31) % 2^32 - 2^31  -- convert to int32 range (-2^31)..(2^31-1) to avoid "number has no integer representation" error while ORing
            local vC, vD, vE, vF = 0|t0, 0|t1, block_length, flags
            for j = 1, 7 do
               v0 = v0 + v4 + W[perm_blake3[j]]
               vC = vC ~ v0
               vC = vC >> 16 | vC << 16
               v8 = v8 + vC
               v4 = v4 ~ v8
               v4 = v4 >> 12 | v4 << 20
               v0 = v0 + v4 + W[perm_blake3[j + 14]]
               vC = vC ~ v0
               vC = vC >> 8 | vC << 24
               v8 = v8 + vC
               v4 = v4 ~ v8
               v4 = v4 >> 7 | v4 << 25
               v1 = v1 + v5 + W[perm_blake3[j + 1]]
               vD = vD ~ v1
               vD = vD >> 16 | vD << 16
               v9 = v9 + vD
               v5 = v5 ~ v9
               v5 = v5 >> 12 | v5 << 20
               v1 = v1 + v5 + W[perm_blake3[j + 2]]
               vD = vD ~ v1
               vD = vD >> 8 | vD << 24
               v9 = v9 + vD
               v5 = v5 ~ v9
               v5 = v5 >> 7 | v5 << 25
               v2 = v2 + v6 + W[perm_blake3[j + 16]]
               vE = vE ~ v2
               vE = vE >> 16 | vE << 16
               vA = vA + vE
               v6 = v6 ~ vA
               v6 = v6 >> 12 | v6 << 20
               v2 = v2 + v6 + W[perm_blake3[j + 7]]
               vE = vE ~ v2
               vE = vE >> 8 | vE << 24
               vA = vA + vE
               v6 = v6 ~ vA
               v6 = v6 >> 7 | v6 << 25
               v3 = v3 + v7 + W[perm_blake3[j + 15]]
               vF = vF ~ v3
               vF = vF >> 16 | vF << 16
               vB = vB + vF
               v7 = v7 ~ vB
               v7 = v7 >> 12 | v7 << 20
               v3 = v3 + v7 + W[perm_blake3[j + 17]]
               vF = vF ~ v3
               vF = vF >> 8 | vF << 24
               vB = vB + vF
               v7 = v7 ~ vB
               v7 = v7 >> 7 | v7 << 25
               v0 = v0 + v5 + W[perm_blake3[j + 21]]
               vF = vF ~ v0
               vF = vF >> 16 | vF << 16
               vA = vA + vF
               v5 = v5 ~ vA
               v5 = v5 >> 12 | v5 << 20
               v0 = v0 + v5 + W[perm_blake3[j + 5]]
               vF = vF ~ v0
               vF = vF >> 8 | vF << 24
               vA = vA + vF
               v5 = v5 ~ vA
               v5 = v5 >> 7 | v5 << 25
               v1 = v1 + v6 + W[perm_blake3[j + 3]]
               vC = vC ~ v1
               vC = vC >> 16 | vC << 16
               vB = vB + vC
               v6 = v6 ~ vB
               v6 = v6 >> 12 | v6 << 20
               v1 = v1 + v6 + W[perm_blake3[j + 6]]
               vC = vC ~ v1
               vC = vC >> 8 | vC << 24
               vB = vB + vC
               v6 = v6 ~ vB
               v6 = v6 >> 7 | v6 << 25
               v2 = v2 + v7 + W[perm_blake3[j + 4]]
               vD = vD ~ v2
               vD = vD >> 16 | vD << 16
               v8 = v8 + vD
               v7 = v7 ~ v8
               v7 = v7 >> 12 | v7 << 20
               v2 = v2 + v7 + W[perm_blake3[j + 18]]
               vD = vD ~ v2
               vD = vD >> 8 | vD << 24
               v8 = v8 + vD
               v7 = v7 ~ v8
               v7 = v7 >> 7 | v7 << 25
               v3 = v3 + v4 + W[perm_blake3[j + 19]]
               vE = vE ~ v3
               vE = vE >> 16 | vE << 16
               v9 = v9 + vE
               v4 = v4 ~ v9
               v4 = v4 >> 12 | v4 << 20
               v3 = v3 + v4 + W[perm_blake3[j + 20]]
               vE = vE ~ v3
               vE = vE >> 8 | vE << 24
               v9 = v9 + vE
               v4 = v4 ~ v9
               v4 = v4 >> 7 | v4 << 25
            end
            if wide_output then
               H_out[ 9] = h1 ~ v8
               H_out[10] = h2 ~ v9
               H_out[11] = h3 ~ vA
               H_out[12] = h4 ~ vB
               H_out[13] = h5 ~ vC
               H_out[14] = h6 ~ vD
               H_out[15] = h7 ~ vE
               H_out[16] = h8 ~ vF
            end
            h1 = v0 ~ v8
            h2 = v1 ~ v9
            h3 = v2 ~ vA
            h4 = v3 ~ vB
            h5 = v4 ~ vC
            h6 = v5 ~ vD
            h7 = v6 ~ vE
            h8 = v7 ~ vF
         end
         H_out[1], H_out[2], H_out[3], H_out[4], H_out[5], H_out[6], H_out[7], H_out[8] = h1, h2, h3, h4, h5, h6, h7, h8
      end

      return XORA5, XOR_BYTE, sha256_feed_64, sha512_feed_128, md5_feed_64, sha1_feed_64, keccak_feed, blake2s_feed_64, blake2b_feed_128, blake3_feed_64
   ]=](av,at,ak,al,aH,ao,ap,aF,ay,am,an,aG)end;O=O or aa;if L=="LIB32"or L=="EMUL"then function ac(aN,aO,aP,aK)local aQ,aR=ay,al;local bm,bn,bo,bp,bq,br,bs,bt=aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]for aS=aP,aP+aK-1,64 do for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=((aT*256+E)*256+aU)*256+aV end;for aM=17,64 do local aT,E=aQ[aM-15],aQ[aM-2]local d7,d8,d9,da=aT/2^7,aT/2^18,E/2^17,E/2^19;aQ[aM]=(O(d7%1*(2^32-1)+d7,d8%1*(2^32-1)+d8,(aT-aT%2^3)/2^3)+aQ[aM-16]+aQ[aM-7]+O(d9%1*(2^32-1)+d9,da%1*(2^32-1)+da,(E-E%2^10)/2^10))%2^32 end;local aT,E,aU,aV,aW,aX,aY,aZ=bm,bn,bo,bp,bq,br,bs,bt;for aM=1,64 do aW=aW%2^32;local db,dc,dd=aW/2^6,aW/2^11,aW*2^7;local de=dd%2^32;local a7=M(aW,aX)+M(-1-aW,aY)+aZ+aR[aM]+aQ[aM]+O(db%1*(2^32-1)+db,dc%1*(2^32-1)+dc,de+(dd-de)/2^32)aZ=aY;aY=aX;aX=aW;aW=a7+aV;aV=aU;aU=E;E=aT%2^32;local df,dg,dh=E/2^2,E/2^13,E*2^10;local di=dh%2^32;aT=a7+M(aV,aU)+M(E,O(aV,aU))+O(df%1*(2^32-1)+df,dg%1*(2^32-1)+dg,di+(dh-di)/2^32)end;bm,bn,bo,bp=(aT+bm)%2^32,(E+bn)%2^32,(aU+bo)%2^32,(aV+bp)%2^32;bq,br,bs,bt=(aW+bq)%2^32,(aX+br)%2^32,(aY+bs)%2^32,(aZ+bt)%2^32 end;aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]=bm,bn,bo,bp,bq,br,bs,bt end;function ad(co,cp,aO,aP,aK)local aQ,cq,cr=ay,ak,al;local cI,cJ,cK,cL,cM,cN,cO,cP=co[1],co[2],co[3],co[4],co[5],co[6],co[7],co[8]local cQ,cR,cS,cT,cU,cV,cW,cX=cp[1],cp[2],cp[3],cp[4],cp[5],cp[6],cp[7],cp[8]for aS=aP,aP+aK-1,128 do for aM=1,16*2 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=((aT*256+E)*256+aU)*256+aV end;for cs=17*2,80*2,2 do local bI,bH,bN,bM=aQ[cs-31],aQ[cs-30],aQ[cs-5],aQ[cs-4]local dj,dk,dl,dm,dn,dp,dq,dr,ds,dt=bN%2^6,bN%2^19,bN%2^29,bM%2^19,bM%2^29,bI%2^1,bI%2^7,bI%2^8,bH%2^1,bH%2^8;local du=O((bH-ds)/2^1+dp*2^31,(bH-dt)/2^8+dr*2^24,(bH-bH%2^7)/2^7+dq*2^25)%2^32+O((bM-dm)/2^19+dk*2^13,dn*2^3+(bN-dl)/2^29,(bM-bM%2^6)/2^6+dj*2^26)%2^32+aQ[cs-14]+aQ[cs-32]local dv=du%2^32;aQ[cs-1]=(O((bI-dp)/2^1+ds*2^31,(bI-dr)/2^8+dt*2^24,(bI-dq)/2^7)+O((bN-dk)/2^19+dm*2^13,dl*2^3+(bM-dn)/2^29,(bN-dj)/2^6)+aQ[cs-15]+aQ[cs-33]+(du-dv)/2^32)%2^32;aQ[cs]=dv end;local bH,bM,c1,ck,bR,bV,bX,ct=cI,cJ,cK,cL,cM,cN,cO,cP;local bI,bN,c2,cl,bS,bW,bY,cu=cQ,cR,cS,cT,cU,cV,cW,cX;for aM=1,80 do local cs=2*aM;local dw,dx,dy,dz,dA,dB=bR%2^9,bR%2^14,bR%2^18,bS%2^9,bS%2^14,bS%2^18;local du=(M(bR,bV)+M(-1-bR,bX))%2^32+ct+cq[aM]+aQ[cs]+O((bR-dx)/2^14+dA*2^18,(bR-dy)/2^18+dB*2^14,dw*2^23+(bS-dz)/2^9)%2^32;local cw=du%2^32;local cx=M(bS,bW)+M(-1-bS,bY)+cu+cr[aM]+aQ[cs-1]+(du-cw)/2^32+O((bS-dA)/2^14+dx*2^18,(bS-dB)/2^18+dy*2^14,dz*2^23+(bR-dw)/2^9)ct=bX;cu=bY;bX=bV;bY=bW;bV=bR;bW=bS;du=cw+ck;bR=du%2^32;bS=(cx+cl+(du-bR)/2^32)%2^32;ck=c1;cl=c2;c1=bM;c2=bN;bM=bH;bN=bI;local dC,dD,dE,dF,dG,dH=bM%2^2,bM%2^7,bM%2^28,bN%2^2,bN%2^7,bN%2^28;du=cw+(M(ck,c1)+M(bM,O(ck,c1)))%2^32+O((bM-dE)/2^28+dH*2^4,dC*2^30+(bN-dF)/2^2,dD*2^25+(bN-dG)/2^7)%2^32;bH=du%2^32;bI=(cx+M(cl,c2)+M(bN,O(cl,c2))+(du-bH)/2^32+O((bN-dH)/2^28+dE*2^4,dF*2^30+(bM-dC)/2^2,dG*2^25+(bM-dD)/2^7))%2^32 end;bH=cI+bH;cI=bH%2^32;cQ=(cQ+bI+(bH-cI)/2^32)%2^32;bH=cJ+bM;cJ=bH%2^32;cR=(cR+bN+(bH-cJ)/2^32)%2^32;bH=cK+c1;cK=bH%2^32;cS=(cS+c2+(bH-cK)/2^32)%2^32;bH=cL+ck;cL=bH%2^32;cT=(cT+cl+(bH-cL)/2^32)%2^32;bH=cM+bR;cM=bH%2^32;cU=(cU+bS+(bH-cM)/2^32)%2^32;bH=cN+bV;cN=bH%2^32;cV=(cV+bW+(bH-cN)/2^32)%2^32;bH=cO+bX;cO=bH%2^32;cW=(cW+bY+(bH-cO)/2^32)%2^32;bH=cP+ct;cP=bH%2^32;cX=(cX+cu+(bH-cP)/2^32)%2^32 end;co[1],co[2],co[3],co[4],co[5],co[6],co[7],co[8]=cI,cJ,cK,cL,cM,cN,cO,cP;cp[1],cp[2],cp[3],cp[4],cp[5],cp[6],cp[7],cp[8]=cQ,cR,cS,cT,cU,cV,cW,cX end;if L=="LIB32"then function ae(aN,aO,aP,aK)local aQ,aR,av=ay,at,av;local bm,bn,bo,bp=aN[1],aN[2],aN[3],aN[4]for aS=aP,aP+aK-1,64 do for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=((aV*256+aU)*256+E)*256+aT end;local aT,E,aU,aV=bm,bn,bo,bp;local dI=25;for aM=1,16 do local dJ=S(M(E,aU)+M(-1-E,aV)+aT+aR[aM]+aQ[aM],dI)+E;dI=av[dI]aT=aV;aV=aU;aU=E;E=dJ end;dI=27;for aM=17,32 do local dJ=S(M(aV,E)+M(-1-aV,aU)+aT+aR[aM]+aQ[(5*aM-4)%16+1],dI)+E;dI=av[dI]aT=aV;aV=aU;aU=E;E=dJ end;dI=28;for aM=33,48 do local dJ=S(O(O(E,aU),aV)+aT+aR[aM]+aQ[(3*aM+2)%16+1],dI)+E;dI=av[dI]aT=aV;aV=aU;aU=E;E=dJ end;dI=26;for aM=49,64 do local dJ=S(O(aU,N(E,-1-aV))+aT+aR[aM]+aQ[(aM*7-7)%16+1],dI)+E;dI=av[dI]aT=aV;aV=aU;aU=E;E=dJ end;bm=(aT+bm)%2^32;bn=(E+bn)%2^32;bo=(aU+bo)%2^32;bp=(aV+bp)%2^32 end;aN[1],aN[2],aN[3],aN[4]=bm,bn,bo,bp end elseif L=="EMUL"then function ae(aN,aO,aP,aK)local aQ,aR,av=ay,at,av;local bm,bn,bo,bp=aN[1],aN[2],aN[3],aN[4]for aS=aP,aP+aK-1,64 do for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=((aV*256+aU)*256+E)*256+aT end;local aT,E,aU,aV=bm,bn,bo,bp;local dI=25;for aM=1,16 do local a7=(M(E,aU)+M(-1-E,aV)+aT+aR[aM]+aQ[aM])%2^32/2^dI;local _=a7%1;dI=av[dI]aT=aV;aV=aU;aU=E;E=_*2^32+a7-_+E end;dI=27;for aM=17,32 do local a7=(M(aV,E)+M(-1-aV,aU)+aT+aR[aM]+aQ[(5*aM-4)%16+1])%2^32/2^dI;local _=a7%1;dI=av[dI]aT=aV;aV=aU;aU=E;E=_*2^32+a7-_+E end;dI=28;for aM=33,48 do local a7=(O(O(E,aU),aV)+aT+aR[aM]+aQ[(3*aM+2)%16+1])%2^32/2^dI;local _=a7%1;dI=av[dI]aT=aV;aV=aU;aU=E;E=_*2^32+a7-_+E end;dI=26;for aM=49,64 do local a7=(O(aU,N(E,-1-aV))+aT+aR[aM]+aQ[(aM*7-7)%16+1])%2^32/2^dI;local _=a7%1;dI=av[dI]aT=aV;aV=aU;aU=E;E=_*2^32+a7-_+E end;bm=(aT+bm)%2^32;bn=(E+bn)%2^32;bo=(aU+bo)%2^32;bp=(aV+bp)%2^32 end;aN[1],aN[2],aN[3],aN[4]=bm,bn,bo,bp end end;function af(aN,aO,aP,aK)local aQ=ay;local bm,bn,bo,bp,bq=aN[1],aN[2],aN[3],aN[4],aN[5]for aS=aP,aP+aK-1,64 do for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=((aT*256+E)*256+aU)*256+aV end;for aM=17,80 do local aT=O(aQ[aM-3],aQ[aM-8],aQ[aM-14],aQ[aM-16])%2^32*2;local E=aT%2^32;aQ[aM]=E+(aT-E)/2^32 end;local aT,E,aU,aV,aW=bm,bn,bo,bp,bq;for aM=1,20 do local dK=aT*2^5;local a7=dK%2^32;a7=a7+(dK-a7)/2^32+M(E,aU)+M(-1-E,aV)+0x5A827999+aQ[aM]+aW;aW=aV;aV=aU;aU=E/2^2;aU=aU%1*(2^32-1)+aU;E=aT;aT=a7%2^32 end;for aM=21,40 do local dK=aT*2^5;local a7=dK%2^32;a7=a7+(dK-a7)/2^32+O(E,aU,aV)+0x6ED9EBA1+aQ[aM]+aW;aW=aV;aV=aU;aU=E/2^2;aU=aU%1*(2^32-1)+aU;E=aT;aT=a7%2^32 end;for aM=41,60 do local dK=aT*2^5;local a7=dK%2^32;a7=a7+(dK-a7)/2^32+M(aV,aU)+M(E,O(aV,aU))+0x8F1BBCDC+aQ[aM]+aW;aW=aV;aV=aU;aU=E/2^2;aU=aU%1*(2^32-1)+aU;E=aT;aT=a7%2^32 end;for aM=61,80 do local dK=aT*2^5;local a7=dK%2^32;a7=a7+(dK-a7)/2^32+O(E,aU,aV)+0xCA62C1D6+aQ[aM]+aW;aW=aV;aV=aU;aU=E/2^2;aU=aU%1*(2^32-1)+aU;E=aT;aT=a7%2^32 end;bm=(aT+bm)%2^32;bn=(E+bn)%2^32;bo=(aU+bo)%2^32;bp=(aV+bp)%2^32;bq=(aW+bq)%2^32 end;aN[1],aN[2],aN[3],aN[4],aN[5]=bm,bn,bo,bp,bq end;function ag(cc,cd,aO,aP,aK,bx)local ce,cf=ao,ap;local bz=bx/8;for aS=aP,aP+aK-1,bx do for aM=1,bz do local aT,E,aU,aV=c(aO,aS+1,aS+4)cc[aM]=O(cc[aM],((aV*256+aU)*256+E)*256+aT)aS=aS+8;aT,E,aU,aV=c(aO,aS-3,aS)cd[aM]=O(cd[aM],((aV*256+aU)*256+E)*256+aT)end;local dL,dM,dN,dO,dP,dQ,dR,dS,dT,dU,dV,dW,dX,dY,dZ,d_,e0,e1,e2,e3,e4,e5,e6,e7,e8,e9,ea,eb,ec,ed,ee,ef,eg,eh,ei,ej,ek,el,em,en,eo,ep,eq,er,es,et,eu,ev,ew,ex=cc[1],cd[1],cc[2],cd[2],cc[3],cd[3],cc[4],cd[4],cc[5],cd[5],cc[6],cd[6],cc[7],cd[7],cc[8],cd[8],cc[9],cd[9],cc[10],cd[10],cc[11],cd[11],cc[12],cd[12],cc[13],cd[13],cc[14],cd[14],cc[15],cd[15],cc[16],cd[16],cc[17],cd[17],cc[18],cd[18],cc[19],cd[19],cc[20],cd[20],cc[21],cd[21],cc[22],cd[22],cc[23],cd[23],cc[24],cd[24],cc[25],cd[25]for bA=1,24 do local ey=O(dL,dV,e4,ee,eo)local ez=O(dM,dW,e5,ef,ep)local eA=O(dN,dX,e6,eg,eq)local eB=O(dO,dY,e7,eh,er)local eC=O(dP,dZ,e8,ei,es)local eD=O(dQ,d_,e9,ej,et)local eE=O(dR,e0,ea,ek,eu)local eF=O(dS,e1,eb,el,ev)local eG=O(dT,e2,ec,em,ew)local eH=O(dU,e3,ed,en,ex)local cg=O(ey,eC*2+(eD%2^32-eD%2^31)/2^31)local ch=O(ez,eD*2+(eC%2^32-eC%2^31)/2^31)local eI=O(cg,dN)local eJ=O(ch,dO)local eK=O(cg,dX)local eL=O(ch,dY)local eM=O(cg,e6)local eN=O(ch,e7)local eO=O(cg,eg)local eP=O(ch,eh)local eQ=O(cg,eq)local eR=O(ch,er)dN=(eK%2^32-eK%2^20)/2^20+eL*2^12;dO=(eL%2^32-eL%2^20)/2^20+eK*2^12;dX=(eO%2^32-eO%2^19)/2^19+eP*2^13;dY=(eP%2^32-eP%2^19)/2^19+eO*2^13;e6=eI*2+(eJ%2^32-eJ%2^31)/2^31;e7=eJ*2+(eI%2^32-eI%2^31)/2^31;eg=eM*2^10+(eN%2^32-eN%2^22)/2^22;eh=eN*2^10+(eM%2^32-eM%2^22)/2^22;eq=eQ*2^2+(eR%2^32-eR%2^30)/2^30;er=eR*2^2+(eQ%2^32-eQ%2^30)/2^30;cg=O(eA,eE*2+(eF%2^32-eF%2^31)/2^31)ch=O(eB,eF*2+(eE%2^32-eE%2^31)/2^31)eI=O(cg,dP)eJ=O(ch,dQ)eK=O(cg,dZ)eL=O(ch,d_)eM=O(cg,e8)eN=O(ch,e9)eO=O(cg,ei)eP=O(ch,ej)eQ=O(cg,es)eR=O(ch,et)dP=(eM%2^32-eM%2^21)/2^21+eN*2^11;dQ=(eN%2^32-eN%2^21)/2^21+eM*2^11;dZ=(eQ%2^32-eQ%2^3)/2^3+eR*2^29%2^32;d_=(eR%2^32-eR%2^3)/2^3+eQ*2^29%2^32;e8=eK*2^6+(eL%2^32-eL%2^26)/2^26;e9=eL*2^6+(eK%2^32-eK%2^26)/2^26;ei=eO*2^15+(eP%2^32-eP%2^17)/2^17;ej=eP*2^15+(eO%2^32-eO%2^17)/2^17;es=(eI%2^32-eI%2^2)/2^2+eJ*2^30%2^32;et=(eJ%2^32-eJ%2^2)/2^2+eI*2^30%2^32;cg=O(eC,eG*2+(eH%2^32-eH%2^31)/2^31)ch=O(eD,eH*2+(eG%2^32-eG%2^31)/2^31)eI=O(cg,dR)eJ=O(ch,dS)eK=O(cg,e0)eL=O(ch,e1)eM=O(cg,ea)eN=O(ch,eb)eO=O(cg,ek)eP=O(ch,el)eQ=O(cg,eu)eR=O(ch,ev)dR=eO*2^21%2^32+(eP%2^32-eP%2^11)/2^11;dS=eP*2^21%2^32+(eO%2^32-eO%2^11)/2^11;e0=eI*2^28%2^32+(eJ%2^32-eJ%2^4)/2^4;e1=eJ*2^28%2^32+(eI%2^32-eI%2^4)/2^4;ea=eM*2^25%2^32+(eN%2^32-eN%2^7)/2^7;eb=eN*2^25%2^32+(eM%2^32-eM%2^7)/2^7;ek=(eQ%2^32-eQ%2^8)/2^8+eR*2^24%2^32;el=(eR%2^32-eR%2^8)/2^8+eQ*2^24%2^32;eu=(eK%2^32-eK%2^9)/2^9+eL*2^23%2^32;ev=(eL%2^32-eL%2^9)/2^9+eK*2^23%2^32;cg=O(eE,ey*2+(ez%2^32-ez%2^31)/2^31)ch=O(eF,ez*2+(ey%2^32-ey%2^31)/2^31)eI=O(cg,dT)eJ=O(ch,dU)eK=O(cg,e2)eL=O(ch,e3)eM=O(cg,ec)eN=O(ch,ed)eO=O(cg,em)eP=O(ch,en)eQ=O(cg,ew)eR=O(ch,ex)dT=eQ*2^14+(eR%2^32-eR%2^18)/2^18;dU=eR*2^14+(eQ%2^32-eQ%2^18)/2^18;e2=eK*2^20%2^32+(eL%2^32-eL%2^12)/2^12;e3=eL*2^20%2^32+(eK%2^32-eK%2^12)/2^12;ec=eO*2^8+(eP%2^32-eP%2^24)/2^24;ed=eP*2^8+(eO%2^32-eO%2^24)/2^24;em=eI*2^27%2^32+(eJ%2^32-eJ%2^5)/2^5;en=eJ*2^27%2^32+(eI%2^32-eI%2^5)/2^5;ew=(eM%2^32-eM%2^25)/2^25+eN*2^7;ex=(eN%2^32-eN%2^25)/2^25+eM*2^7;cg=O(eG,eA*2+(eB%2^32-eB%2^31)/2^31)ch=O(eH,eB*2+(eA%2^32-eA%2^31)/2^31)eK=O(cg,dV)eL=O(ch,dW)eM=O(cg,e4)eN=O(ch,e5)eO=O(cg,ee)eP=O(ch,ef)eQ=O(cg,eo)eR=O(ch,ep)dV=eM*2^3+(eN%2^32-eN%2^29)/2^29;dW=eN*2^3+(eM%2^32-eM%2^29)/2^29;e4=eQ*2^18+(eR%2^32-eR%2^14)/2^14;e5=eR*2^18+(eQ%2^32-eQ%2^14)/2^14;ee=(eK%2^32-eK%2^28)/2^28+eL*2^4;ef=(eL%2^32-eL%2^28)/2^28+eK*2^4;eo=(eO%2^32-eO%2^23)/2^23+eP*2^9;ep=(eP%2^32-eP%2^23)/2^23+eO*2^9;dL=O(cg,dL)dM=O(ch,dM)dL,dN,dP,dR,dT=O(dL,M(-1-dN,dP)),O(dN,M(-1-dP,dR)),O(dP,M(-1-dR,dT)),O(dR,M(-1-dT,dL)),O(dT,M(-1-dL,dN))dM,dO,dQ,dS,dU=O(dM,M(-1-dO,dQ)),O(dO,M(-1-dQ,dS)),O(dQ,M(-1-dS,dU)),O(dS,M(-1-dU,dM)),O(dU,M(-1-dM,dO))dV,dX,dZ,e0,e2=O(e0,M(-1-e2,dV)),O(e2,M(-1-dV,dX)),O(dV,M(-1-dX,dZ)),O(dX,M(-1-dZ,e0)),O(dZ,M(-1-e0,e2))dW,dY,d_,e1,e3=O(e1,M(-1-e3,dW)),O(e3,M(-1-dW,dY)),O(dW,M(-1-dY,d_)),O(dY,M(-1-d_,e1)),O(d_,M(-1-e1,e3))e4,e6,e8,ea,ec=O(e6,M(-1-e8,ea)),O(e8,M(-1-ea,ec)),O(ea,M(-1-ec,e4)),O(ec,M(-1-e4,e6)),O(e4,M(-1-e6,e8))e5,e7,e9,eb,ed=O(e7,M(-1-e9,eb)),O(e9,M(-1-eb,ed)),O(eb,M(-1-ed,e5)),O(ed,M(-1-e5,e7)),O(e5,M(-1-e7,e9))ee,eg,ei,ek,em=O(em,M(-1-ee,eg)),O(ee,M(-1-eg,ei)),O(eg,M(-1-ei,ek)),O(ei,M(-1-ek,em)),O(ek,M(-1-em,ee))ef,eh,ej,el,en=O(en,M(-1-ef,eh)),O(ef,M(-1-eh,ej)),O(eh,M(-1-ej,el)),O(ej,M(-1-el,en)),O(el,M(-1-en,ef))eo,eq,es,eu,ew=O(es,M(-1-eu,ew)),O(eu,M(-1-ew,eo)),O(ew,M(-1-eo,eq)),O(eo,M(-1-eq,es)),O(eq,M(-1-es,eu))ep,er,et,ev,ex=O(et,M(-1-ev,ex)),O(ev,M(-1-ex,ep)),O(ex,M(-1-ep,er)),O(ep,M(-1-er,et)),O(er,M(-1-et,ev))dL=O(dL,ce[bA])dM=dM+cf[bA]end;cc[1]=dL;cd[1]=dM;cc[2]=dN;cd[2]=dO;cc[3]=dP;cd[3]=dQ;cc[4]=dR;cd[4]=dS;cc[5]=dT;cd[5]=dU;cc[6]=dV;cd[6]=dW;cc[7]=dX;cd[7]=dY;cc[8]=dZ;cd[8]=d_;cc[9]=e0;cd[9]=e1;cc[10]=e2;cd[10]=e3;cc[11]=e4;cd[11]=e5;cc[12]=e6;cd[12]=e7;cc[13]=e8;cd[13]=e9;cc[14]=ea;cd[14]=eb;cc[15]=ec;cd[15]=ed;cc[16]=ee;cd[16]=ef;cc[17]=eg;cd[17]=eh;cc[18]=ei;cd[18]=ej;cc[19]=ek;cd[19]=el;cc[20]=em;cd[20]=en;cc[21]=eo;cd[21]=ep;cc[22]=eq;cd[22]=er;cc[23]=es;cd[23]=et;cc[24]=eu;cd[24]=ev;cc[25]=ew;cd[25]=ex end end;function ah(aN,aO,aP,aK,bj,bk,bl)local aQ=ay;local bm,bn,bo,bp,bq,br,bs,bt=aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]for aS=aP,aP+aK-1,64 do if aO then for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=((aV*256+aU)*256+E)*256+aT end end;local eS,eT,eU,eV,eW,eX,eY,eZ=bm,bn,bo,bp,bq,br,bs,bt;local e_,f0,f1,f2,f3,f4,f5,f6=an[1],an[2],an[3],an[4],an[5],an[6],an[7],an[8]bj=bj+(bk or 64)local c_=bj%2^32;local d0=(bj-c_)/2^32;f3=O(f3,c_)f4=O(f4,d0)if bk then f5=-1-f5 end;if bl then f6=-1-f6 end;for aM=1,10 do local bu=aF[aM]eS=eS+eW+aQ[bu[1]]f3=O(f3,eS)%2^32/2^16;f3=f3%1*(2^32-1)+f3;e_=e_+f3;eW=O(eW,e_)%2^32/2^12;eW=eW%1*(2^32-1)+eW;eS=eS+eW+aQ[bu[2]]f3=O(f3,eS)%2^32/2^8;f3=f3%1*(2^32-1)+f3;e_=e_+f3;eW=O(eW,e_)%2^32/2^7;eW=eW%1*(2^32-1)+eW;eT=eT+eX+aQ[bu[3]]f4=O(f4,eT)%2^32/2^16;f4=f4%1*(2^32-1)+f4;f0=f0+f4;eX=O(eX,f0)%2^32/2^12;eX=eX%1*(2^32-1)+eX;eT=eT+eX+aQ[bu[4]]f4=O(f4,eT)%2^32/2^8;f4=f4%1*(2^32-1)+f4;f0=f0+f4;eX=O(eX,f0)%2^32/2^7;eX=eX%1*(2^32-1)+eX;eU=eU+eY+aQ[bu[5]]f5=O(f5,eU)%2^32/2^16;f5=f5%1*(2^32-1)+f5;f1=f1+f5;eY=O(eY,f1)%2^32/2^12;eY=eY%1*(2^32-1)+eY;eU=eU+eY+aQ[bu[6]]f5=O(f5,eU)%2^32/2^8;f5=f5%1*(2^32-1)+f5;f1=f1+f5;eY=O(eY,f1)%2^32/2^7;eY=eY%1*(2^32-1)+eY;eV=eV+eZ+aQ[bu[7]]f6=O(f6,eV)%2^32/2^16;f6=f6%1*(2^32-1)+f6;f2=f2+f6;eZ=O(eZ,f2)%2^32/2^12;eZ=eZ%1*(2^32-1)+eZ;eV=eV+eZ+aQ[bu[8]]f6=O(f6,eV)%2^32/2^8;f6=f6%1*(2^32-1)+f6;f2=f2+f6;eZ=O(eZ,f2)%2^32/2^7;eZ=eZ%1*(2^32-1)+eZ;eS=eS+eX+aQ[bu[9]]f6=O(f6,eS)%2^32/2^16;f6=f6%1*(2^32-1)+f6;f1=f1+f6;eX=O(eX,f1)%2^32/2^12;eX=eX%1*(2^32-1)+eX;eS=eS+eX+aQ[bu[10]]f6=O(f6,eS)%2^32/2^8;f6=f6%1*(2^32-1)+f6;f1=f1+f6;eX=O(eX,f1)%2^32/2^7;eX=eX%1*(2^32-1)+eX;eT=eT+eY+aQ[bu[11]]f3=O(f3,eT)%2^32/2^16;f3=f3%1*(2^32-1)+f3;f2=f2+f3;eY=O(eY,f2)%2^32/2^12;eY=eY%1*(2^32-1)+eY;eT=eT+eY+aQ[bu[12]]f3=O(f3,eT)%2^32/2^8;f3=f3%1*(2^32-1)+f3;f2=f2+f3;eY=O(eY,f2)%2^32/2^7;eY=eY%1*(2^32-1)+eY;eU=eU+eZ+aQ[bu[13]]f4=O(f4,eU)%2^32/2^16;f4=f4%1*(2^32-1)+f4;e_=e_+f4;eZ=O(eZ,e_)%2^32/2^12;eZ=eZ%1*(2^32-1)+eZ;eU=eU+eZ+aQ[bu[14]]f4=O(f4,eU)%2^32/2^8;f4=f4%1*(2^32-1)+f4;e_=e_+f4;eZ=O(eZ,e_)%2^32/2^7;eZ=eZ%1*(2^32-1)+eZ;eV=eV+eW+aQ[bu[15]]f5=O(f5,eV)%2^32/2^16;f5=f5%1*(2^32-1)+f5;f0=f0+f5;eW=O(eW,f0)%2^32/2^12;eW=eW%1*(2^32-1)+eW;eV=eV+eW+aQ[bu[16]]f5=O(f5,eV)%2^32/2^8;f5=f5%1*(2^32-1)+f5;f0=f0+f5;eW=O(eW,f0)%2^32/2^7;eW=eW%1*(2^32-1)+eW end;bm=O(bm,eS,e_)bn=O(bn,eT,f0)bo=O(bo,eU,f1)bp=O(bp,eV,f2)bq=O(bq,eW,f3)br=O(br,eX,f4)bs=O(bs,eY,f5)bt=O(bt,eZ,f6)end;aN[1],aN[2],aN[3],aN[4],aN[5],aN[6],aN[7],aN[8]=bm,bn,bo,bp,bq,br,bs,bt;return bj end;function ai(co,cp,aO,aP,aK,bj,bk,bl)local aQ=ay;local cI,cJ,cK,cL,cM,cN,cO,cP=co[1],co[2],co[3],co[4],co[5],co[6],co[7],co[8]local cQ,cR,cS,cT,cU,cV,cW,cX=cp[1],cp[2],cp[3],cp[4],cp[5],cp[6],cp[7],cp[8]for aS=aP,aP+aK-1,128 do if aO then for aM=1,32 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=((aV*256+aU)*256+E)*256+aT end end;local f7,f8,f9,fa,fb,fc,fd,fe=cI,cJ,cK,cL,cM,cN,cO,cP;local ff,fg,fh,fi,fj,fk,fl,fm=cQ,cR,cS,cT,cU,cV,cW,cX;local fn,fo,fp,fq,fr,fs,ft,fu=am[1],am[2],am[3],am[4],am[5],am[6],am[7],am[8]local fv,fw,fx,fy,fz,fA,fB,fC=an[1],an[2],an[3],an[4],an[5],an[6],an[7],an[8]bj=bj+(bk or 128)local cY=bj%2^32;local cZ=(bj-cY)/2^32;fr=O(fr,cY)fz=O(fz,cZ)if bk then ft=-1-ft;fB=-1-fB end;if bl then fu=-1-fu;fC=-1-fC end;for aM=1,12 do local bu=aF[aM]local q=bu[1]*2;local a7=f7%2^32+fb%2^32+aQ[q-1]f7=a7%2^32;ff=ff+fj+(a7-f7)/2^32+aQ[q]fr,fz=O(fz,ff),O(fr,f7)a7=fn%2^32+fr%2^32;fn=a7%2^32;fv=fv+fz+(a7-fn)/2^32;fb,fj=O(fb,fn),O(fj,fv)local cw,cx=fb%2^24,fj%2^24;fb,fj=(fb-cw)/2^24%2^8+cx*2^8,(fj-cx)/2^24%2^8+cw*2^8;q=bu[2]*2;a7=f7%2^32+fb%2^32+aQ[q-1]f7=a7%2^32;ff=ff+fj+(a7-f7)/2^32+aQ[q]fr,fz=O(fr,f7),O(fz,ff)cw,cx=fr%2^16,fz%2^16;fr,fz=(fr-cw)/2^16%2^16+cx*2^16,(fz-cx)/2^16%2^16+cw*2^16;a7=fn%2^32+fr%2^32;fn=a7%2^32;fv=fv+fz+(a7-fn)/2^32;fb,fj=O(fb,fn),O(fj,fv)cw,cx=fb%2^31,fj%2^31;fb,fj=cw*2^1+(fj-cx)/2^31%2^1,cx*2^1+(fb-cw)/2^31%2^1;q=bu[3]*2;a7=f8%2^32+fc%2^32+aQ[q-1]f8=a7%2^32;fg=fg+fk+(a7-f8)/2^32+aQ[q]fs,fA=O(fA,fg),O(fs,f8)a7=fo%2^32+fs%2^32;fo=a7%2^32;fw=fw+fA+(a7-fo)/2^32;fc,fk=O(fc,fo),O(fk,fw)cw,cx=fc%2^24,fk%2^24;fc,fk=(fc-cw)/2^24%2^8+cx*2^8,(fk-cx)/2^24%2^8+cw*2^8;q=bu[4]*2;a7=f8%2^32+fc%2^32+aQ[q-1]f8=a7%2^32;fg=fg+fk+(a7-f8)/2^32+aQ[q]fs,fA=O(fs,f8),O(fA,fg)cw,cx=fs%2^16,fA%2^16;fs,fA=(fs-cw)/2^16%2^16+cx*2^16,(fA-cx)/2^16%2^16+cw*2^16;a7=fo%2^32+fs%2^32;fo=a7%2^32;fw=fw+fA+(a7-fo)/2^32;fc,fk=O(fc,fo),O(fk,fw)cw,cx=fc%2^31,fk%2^31;fc,fk=cw*2^1+(fk-cx)/2^31%2^1,cx*2^1+(fc-cw)/2^31%2^1;q=bu[5]*2;a7=f9%2^32+fd%2^32+aQ[q-1]f9=a7%2^32;fh=fh+fl+(a7-f9)/2^32+aQ[q]ft,fB=O(fB,fh),O(ft,f9)a7=fp%2^32+ft%2^32;fp=a7%2^32;fx=fx+fB+(a7-fp)/2^32;fd,fl=O(fd,fp),O(fl,fx)cw,cx=fd%2^24,fl%2^24;fd,fl=(fd-cw)/2^24%2^8+cx*2^8,(fl-cx)/2^24%2^8+cw*2^8;q=bu[6]*2;a7=f9%2^32+fd%2^32+aQ[q-1]f9=a7%2^32;fh=fh+fl+(a7-f9)/2^32+aQ[q]ft,fB=O(ft,f9),O(fB,fh)cw,cx=ft%2^16,fB%2^16;ft,fB=(ft-cw)/2^16%2^16+cx*2^16,(fB-cx)/2^16%2^16+cw*2^16;a7=fp%2^32+ft%2^32;fp=a7%2^32;fx=fx+fB+(a7-fp)/2^32;fd,fl=O(fd,fp),O(fl,fx)cw,cx=fd%2^31,fl%2^31;fd,fl=cw*2^1+(fl-cx)/2^31%2^1,cx*2^1+(fd-cw)/2^31%2^1;q=bu[7]*2;a7=fa%2^32+fe%2^32+aQ[q-1]fa=a7%2^32;fi=fi+fm+(a7-fa)/2^32+aQ[q]fu,fC=O(fC,fi),O(fu,fa)a7=fq%2^32+fu%2^32;fq=a7%2^32;fy=fy+fC+(a7-fq)/2^32;fe,fm=O(fe,fq),O(fm,fy)cw,cx=fe%2^24,fm%2^24;fe,fm=(fe-cw)/2^24%2^8+cx*2^8,(fm-cx)/2^24%2^8+cw*2^8;q=bu[8]*2;a7=fa%2^32+fe%2^32+aQ[q-1]fa=a7%2^32;fi=fi+fm+(a7-fa)/2^32+aQ[q]fu,fC=O(fu,fa),O(fC,fi)cw,cx=fu%2^16,fC%2^16;fu,fC=(fu-cw)/2^16%2^16+cx*2^16,(fC-cx)/2^16%2^16+cw*2^16;a7=fq%2^32+fu%2^32;fq=a7%2^32;fy=fy+fC+(a7-fq)/2^32;fe,fm=O(fe,fq),O(fm,fy)cw,cx=fe%2^31,fm%2^31;fe,fm=cw*2^1+(fm-cx)/2^31%2^1,cx*2^1+(fe-cw)/2^31%2^1;q=bu[9]*2;a7=f7%2^32+fc%2^32+aQ[q-1]f7=a7%2^32;ff=ff+fk+(a7-f7)/2^32+aQ[q]fu,fC=O(fC,ff),O(fu,f7)a7=fp%2^32+fu%2^32;fp=a7%2^32;fx=fx+fC+(a7-fp)/2^32;fc,fk=O(fc,fp),O(fk,fx)cw,cx=fc%2^24,fk%2^24;fc,fk=(fc-cw)/2^24%2^8+cx*2^8,(fk-cx)/2^24%2^8+cw*2^8;q=bu[10]*2;a7=f7%2^32+fc%2^32+aQ[q-1]f7=a7%2^32;ff=ff+fk+(a7-f7)/2^32+aQ[q]fu,fC=O(fu,f7),O(fC,ff)cw,cx=fu%2^16,fC%2^16;fu,fC=(fu-cw)/2^16%2^16+cx*2^16,(fC-cx)/2^16%2^16+cw*2^16;a7=fp%2^32+fu%2^32;fp=a7%2^32;fx=fx+fC+(a7-fp)/2^32;fc,fk=O(fc,fp),O(fk,fx)cw,cx=fc%2^31,fk%2^31;fc,fk=cw*2^1+(fk-cx)/2^31%2^1,cx*2^1+(fc-cw)/2^31%2^1;q=bu[11]*2;a7=f8%2^32+fd%2^32+aQ[q-1]f8=a7%2^32;fg=fg+fl+(a7-f8)/2^32+aQ[q]fr,fz=O(fz,fg),O(fr,f8)a7=fq%2^32+fr%2^32;fq=a7%2^32;fy=fy+fz+(a7-fq)/2^32;fd,fl=O(fd,fq),O(fl,fy)cw,cx=fd%2^24,fl%2^24;fd,fl=(fd-cw)/2^24%2^8+cx*2^8,(fl-cx)/2^24%2^8+cw*2^8;q=bu[12]*2;a7=f8%2^32+fd%2^32+aQ[q-1]f8=a7%2^32;fg=fg+fl+(a7-f8)/2^32+aQ[q]fr,fz=O(fr,f8),O(fz,fg)cw,cx=fr%2^16,fz%2^16;fr,fz=(fr-cw)/2^16%2^16+cx*2^16,(fz-cx)/2^16%2^16+cw*2^16;a7=fq%2^32+fr%2^32;fq=a7%2^32;fy=fy+fz+(a7-fq)/2^32;fd,fl=O(fd,fq),O(fl,fy)cw,cx=fd%2^31,fl%2^31;fd,fl=cw*2^1+(fl-cx)/2^31%2^1,cx*2^1+(fd-cw)/2^31%2^1;q=bu[13]*2;a7=f9%2^32+fe%2^32+aQ[q-1]f9=a7%2^32;fh=fh+fm+(a7-f9)/2^32+aQ[q]fs,fA=O(fA,fh),O(fs,f9)a7=fn%2^32+fs%2^32;fn=a7%2^32;fv=fv+fA+(a7-fn)/2^32;fe,fm=O(fe,fn),O(fm,fv)cw,cx=fe%2^24,fm%2^24;fe,fm=(fe-cw)/2^24%2^8+cx*2^8,(fm-cx)/2^24%2^8+cw*2^8;q=bu[14]*2;a7=f9%2^32+fe%2^32+aQ[q-1]f9=a7%2^32;fh=fh+fm+(a7-f9)/2^32+aQ[q]fs,fA=O(fs,f9),O(fA,fh)cw,cx=fs%2^16,fA%2^16;fs,fA=(fs-cw)/2^16%2^16+cx*2^16,(fA-cx)/2^16%2^16+cw*2^16;a7=fn%2^32+fs%2^32;fn=a7%2^32;fv=fv+fA+(a7-fn)/2^32;fe,fm=O(fe,fn),O(fm,fv)cw,cx=fe%2^31,fm%2^31;fe,fm=cw*2^1+(fm-cx)/2^31%2^1,cx*2^1+(fe-cw)/2^31%2^1;q=bu[15]*2;a7=fa%2^32+fb%2^32+aQ[q-1]fa=a7%2^32;fi=fi+fj+(a7-fa)/2^32+aQ[q]ft,fB=O(fB,fi),O(ft,fa)a7=fo%2^32+ft%2^32;fo=a7%2^32;fw=fw+fB+(a7-fo)/2^32;fb,fj=O(fb,fo),O(fj,fw)cw,cx=fb%2^24,fj%2^24;fb,fj=(fb-cw)/2^24%2^8+cx*2^8,(fj-cx)/2^24%2^8+cw*2^8;q=bu[16]*2;a7=fa%2^32+fb%2^32+aQ[q-1]fa=a7%2^32;fi=fi+fj+(a7-fa)/2^32+aQ[q]ft,fB=O(ft,fa),O(fB,fi)cw,cx=ft%2^16,fB%2^16;ft,fB=(ft-cw)/2^16%2^16+cx*2^16,(fB-cx)/2^16%2^16+cw*2^16;a7=fo%2^32+ft%2^32;fo=a7%2^32;fw=fw+fB+(a7-fo)/2^32;fb,fj=O(fb,fo),O(fj,fw)cw,cx=fb%2^31,fj%2^31;fb,fj=cw*2^1+(fj-cx)/2^31%2^1,cx*2^1+(fb-cw)/2^31%2^1 end;cI=O(cI,f7,fn)%2^32;cJ=O(cJ,f8,fo)%2^32;cK=O(cK,f9,fp)%2^32;cL=O(cL,fa,fq)%2^32;cM=O(cM,fb,fr)%2^32;cN=O(cN,fc,fs)%2^32;cO=O(cO,fd,ft)%2^32;cP=O(cP,fe,fu)%2^32;cQ=O(cQ,ff,fv)%2^32;cR=O(cR,fg,fw)%2^32;cS=O(cS,fh,fx)%2^32;cT=O(cT,fi,fy)%2^32;cU=O(cU,fj,fz)%2^32;cV=O(cV,fk,fA)%2^32;cW=O(cW,fl,fB)%2^32;cX=O(cX,fm,fC)%2^32 end;co[1],co[2],co[3],co[4],co[5],co[6],co[7],co[8]=cI,cJ,cK,cL,cM,cN,cO,cP;cp[1],cp[2],cp[3],cp[4],cp[5],cp[6],cp[7],cp[8]=cQ,cR,cS,cT,cU,cV,cW,cX;return bj end;function aj(aO,aP,aK,d1,d2,d3,d4,d5,d6)d6=d6 or 64;local aQ=ay;local bm,bn,bo,bp,bq,br,bs,bt=d3[1],d3[2],d3[3],d3[4],d3[5],d3[6],d3[7],d3[8]d4=d4 or d3;for aS=aP,aP+aK-1,64 do if aO then for aM=1,16 do aS=aS+4;local aT,E,aU,aV=c(aO,aS-3,aS)aQ[aM]=((aV*256+aU)*256+E)*256+aT end end;local eS,eT,eU,eV,eW,eX,eY,eZ=bm,bn,bo,bp,bq,br,bs,bt;local e_,f0,f1,f2=an[1],an[2],an[3],an[4]local f3=d2%2^32;local f4=(d2-f3)/2^32;local f5,f6=d6,d1;for aM=1,7 do eS=eS+eW+aQ[aG[aM]]f3=O(f3,eS)%2^32/2^16;f3=f3%1*(2^32-1)+f3;e_=e_+f3;eW=O(eW,e_)%2^32/2^12;eW=eW%1*(2^32-1)+eW;eS=eS+eW+aQ[aG[aM+14]]f3=O(f3,eS)%2^32/2^8;f3=f3%1*(2^32-1)+f3;e_=e_+f3;eW=O(eW,e_)%2^32/2^7;eW=eW%1*(2^32-1)+eW;eT=eT+eX+aQ[aG[aM+1]]f4=O(f4,eT)%2^32/2^16;f4=f4%1*(2^32-1)+f4;f0=f0+f4;eX=O(eX,f0)%2^32/2^12;eX=eX%1*(2^32-1)+eX;eT=eT+eX+aQ[aG[aM+2]]f4=O(f4,eT)%2^32/2^8;f4=f4%1*(2^32-1)+f4;f0=f0+f4;eX=O(eX,f0)%2^32/2^7;eX=eX%1*(2^32-1)+eX;eU=eU+eY+aQ[aG[aM+16]]f5=O(f5,eU)%2^32/2^16;f5=f5%1*(2^32-1)+f5;f1=f1+f5;eY=O(eY,f1)%2^32/2^12;eY=eY%1*(2^32-1)+eY;eU=eU+eY+aQ[aG[aM+7]]f5=O(f5,eU)%2^32/2^8;f5=f5%1*(2^32-1)+f5;f1=f1+f5;eY=O(eY,f1)%2^32/2^7;eY=eY%1*(2^32-1)+eY;eV=eV+eZ+aQ[aG[aM+15]]f6=O(f6,eV)%2^32/2^16;f6=f6%1*(2^32-1)+f6;f2=f2+f6;eZ=O(eZ,f2)%2^32/2^12;eZ=eZ%1*(2^32-1)+eZ;eV=eV+eZ+aQ[aG[aM+17]]f6=O(f6,eV)%2^32/2^8;f6=f6%1*(2^32-1)+f6;f2=f2+f6;eZ=O(eZ,f2)%2^32/2^7;eZ=eZ%1*(2^32-1)+eZ;eS=eS+eX+aQ[aG[aM+21]]f6=O(f6,eS)%2^32/2^16;f6=f6%1*(2^32-1)+f6;f1=f1+f6;eX=O(eX,f1)%2^32/2^12;eX=eX%1*(2^32-1)+eX;eS=eS+eX+aQ[aG[aM+5]]f6=O(f6,eS)%2^32/2^8;f6=f6%1*(2^32-1)+f6;f1=f1+f6;eX=O(eX,f1)%2^32/2^7;eX=eX%1*(2^32-1)+eX;eT=eT+eY+aQ[aG[aM+3]]f3=O(f3,eT)%2^32/2^16;f3=f3%1*(2^32-1)+f3;f2=f2+f3;eY=O(eY,f2)%2^32/2^12;eY=eY%1*(2^32-1)+eY;eT=eT+eY+aQ[aG[aM+6]]f3=O(f3,eT)%2^32/2^8;f3=f3%1*(2^32-1)+f3;f2=f2+f3;eY=O(eY,f2)%2^32/2^7;eY=eY%1*(2^32-1)+eY;eU=eU+eZ+aQ[aG[aM+4]]f4=O(f4,eU)%2^32/2^16;f4=f4%1*(2^32-1)+f4;e_=e_+f4;eZ=O(eZ,e_)%2^32/2^12;eZ=eZ%1*(2^32-1)+eZ;eU=eU+eZ+aQ[aG[aM+18]]f4=O(f4,eU)%2^32/2^8;f4=f4%1*(2^32-1)+f4;e_=e_+f4;eZ=O(eZ,e_)%2^32/2^7;eZ=eZ%1*(2^32-1)+eZ;eV=eV+eW+aQ[aG[aM+19]]f5=O(f5,eV)%2^32/2^16;f5=f5%1*(2^32-1)+f5;f0=f0+f5;eW=O(eW,f0)%2^32/2^12;eW=eW%1*(2^32-1)+eW;eV=eV+eW+aQ[aG[aM+20]]f5=O(f5,eV)%2^32/2^8;f5=f5%1*(2^32-1)+f5;f0=f0+f5;eW=O(eW,f0)%2^32/2^7;eW=eW%1*(2^32-1)+eW end;if d5 then d4[9]=O(bm,e_)d4[10]=O(bn,f0)d4[11]=O(bo,f1)d4[12]=O(bp,f2)d4[13]=O(bq,f3)d4[14]=O(br,f4)d4[15]=O(bs,f5)d4[16]=O(bt,f6)end;bm=O(eS,e_)bn=O(eT,f0)bo=O(eU,f1)bp=O(eV,f2)bq=O(eW,f3)br=O(eX,f4)bs=O(eY,f5)bt=O(eZ,f6)end;d4[1],d4[2],d4[3],d4[4],d4[5],d4[6],d4[7],d4[8]=bm,bn,bo,bp,bq,br,bs,bt end end;do local function fD(fE,fF,fG,fH)local H,fI,fJ,fK={},0.0,0.0,1.0;for aM=1,fH do for q=m(1,aM+1-#fF),l(aM,#fE)do fI=fI+fG*fE[q]*fF[aM+1-q]end;local fL=fI%2^24;H[aM]=j(fL)fI=(fI-fL)/2^24;fJ=fJ+fL*fK;fK=fK*2^24 end;return H,fJ end;local Z,fM,fN,p,fO,fP=0,{4,1,2,-2,2},4,{1},an,am;repeat fN=fN+fM[fN%6]local aV=1;repeat aV=aV+fM[aV%6]if aV*aV>fN then local fQ=fN^(1/3)local fR=fQ*2^40;fR=fD({fR-fR%1},p,1.0,2)local I,fS=fD(fR,fD(fR,fR,1.0,4),-1.0,4)local fT=fR[2]%65536*65536+j(fR[1]/256)local fU=fR[1]%256*16777216+j(fS*2^-56/3*fQ/fN)if Z<16 then fQ=fN^(1/2)fR=fQ*2^40;fR=fD({fR-fR%1},p,1.0,2)I,fS=fD(fR,fR,-1.0,2)local fT=fR[2]%65536*65536+j(fR[1]/256)local fU=fR[1]%256*16777216+j(fS*2^-17/fQ)local Z=Z%8+1;aq[224][Z]=fU;fO[Z],fP[Z]=fT,fU+fT*aD;if Z>7 then fO,fP=as[384],ar[384]end end;Z=Z+1;al[Z],ak[Z]=fT,fU%aC+fT*aD;break end until fN%aV==0 until Z>79 end;for fV=224,256,32 do local co,cp={}if aw then for aM=1,8 do co[aM]=aa(am[aM])end else cp={}for aM=1,8 do co[aM]=aa(am[aM])cp[aM]=aa(an[aM])end end;ad(co,cp,"SHA-512/"..tostring(fV).."\128"..e("\0",115).."\88",0,128)ar[fV]=co;as[fV]=cp end;do local fW,fX,fY=math.sin,math.abs,math.modf;for Z=1,64 do local fT,fU=fY(fX(fW(Z))*2^16)at[Z]=fT*65536+j(fU*2^16)end end;do local fZ=29;local function f_()local X=fZ%2;fZ=W((fZ-X)/2,142*X)return X end;for Z=1,24 do local fU,s=0;for I=1,6 do s=s and s*s*2 or 1;fU=fU+f_()*s end;local fT=f_()*s;ap[Z],ao[Z]=fT,fU+fT*aE end end;if L=="FFI"then al=D.new("uint32_t[?]",#al+1,0,unpack(al))ak=D.new("int64_t[?]",#ak+1,0,unpack(ak))if aE==0 then ao=D.new("uint32_t[?]",#ao+1,0,unpack(ao))ap=D.new("uint32_t[?]",#ap+1,0,unpack(ap))else ao=D.new("int64_t[?]",#ao+1,0,unpack(ao))end end;local function g0(fV,g1)local aN,g2,g3={unpack(aq[fV])},0.0,""local function g4(g5)if g5 then if g3 then g2=g2+#g5;local aP=0;if g3~=""and#g3+#g5>=64 then aP=64-#g3;ac(aN,g3 ..f(g5,1,aP),0,64)g3=""end;local aK=#g5-aP;local g6=aK%64;ac(aN,g5,aP,aK-g6)g3=g3 ..f(g5,#g5+1-g6)return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if g3 then local g7={g3,"\128",e("\0",(-9-g2)%64+1)}g3=nil;g2=g2*8/256^7;for aM=4,10 do g2=g2%1*256;g7[aM]=d(j(g2))end;g7=b(g7)ac(aN,g7,0,#g7)local g8=fV/32;for aM=1,g8 do aN[aM]=V(aN[aM])end;aN=b(aN,"",1,g8)end;return aN end end;if g1 then return g4(g1)()else return g4 end end;local function g9(fV,g1)local g2,g3,co,cp=0.0,"",{unpack(ar[fV])},not aw and{unpack(as[fV])}local function g4(g5)if g5 then if g3 then g2=g2+#g5;local aP=0;if g3~=""and#g3+#g5>=128 then aP=128-#g3;ad(co,cp,g3 ..f(g5,1,aP),0,128)g3=""end;local aK=#g5-aP;local g6=aK%128;ad(co,cp,g5,aP,aK-g6)g3=g3 ..f(g5,#g5+1-g6)return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if g3 then local g7={g3,"\128",e("\0",(-17-g2)%128+9)}g3=nil;g2=g2*8/256^7;for aM=4,10 do g2=g2%1*256;g7[aM]=d(j(g2))end;g7=b(g7)ad(co,cp,g7,0,#g7)local g8=k(fV/64)if aw then for aM=1,g8 do co[aM]=aw(co[aM])end else for aM=1,g8 do co[aM]=V(cp[aM])..V(co[aM])end;cp=nil end;co=f(b(co,"",1,g8),1,fV/4)end;return co end end;if g1 then return g4(g1)()else return g4 end end;local function ga(g1)local aN,g2,g3={unpack(au,1,4)},0.0,""local function g4(g5)if g5 then if g3 then g2=g2+#g5;local aP=0;if g3~=""and#g3+#g5>=64 then aP=64-#g3;ae(aN,g3 ..f(g5,1,aP),0,64)g3=""end;local aK=#g5-aP;local g6=aK%64;ae(aN,g5,aP,aK-g6)g3=g3 ..f(g5,#g5+1-g6)return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if g3 then local g7={g3,"\128",e("\0",(-9-g2)%64)}g3=nil;g2=g2*8;for aM=4,11 do local gb=g2%256;g7[aM]=d(gb)g2=(g2-gb)/256 end;g7=b(g7)ae(aN,g7,0,#g7)for aM=1,4 do aN[aM]=V(aN[aM])end;aN=g(b(aN),"(..)(..)(..)(..)","%4%3%2%1")end;return aN end end;if g1 then return g4(g1)()else return g4 end end;local function gc(g1)local aN,g2,g3={unpack(au)},0.0,""local function g4(g5)if g5 then if g3 then g2=g2+#g5;local aP=0;if g3~=""and#g3+#g5>=64 then aP=64-#g3;af(aN,g3 ..f(g5,1,aP),0,64)g3=""end;local aK=#g5-aP;local g6=aK%64;af(aN,g5,aP,aK-g6)g3=g3 ..f(g5,#g5+1-g6)return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if g3 then local g7={g3,"\128",e("\0",(-9-g2)%64+1)}g3=nil;g2=g2*8/256^7;for aM=4,10 do g2=g2%1*256;g7[aM]=d(j(g2))end;g7=b(g7)af(aN,g7,0,#g7)for aM=1,5 do aN[aM]=V(aN[aM])end;aN=b(aN)end;return aN end end;if g1 then return g4(g1)()else return g4 end end;local function gd(bx,ge,gf,g1)if type(ge)~="number"then error("Argument 'digest_size_in_bytes' must be a number",2)end;local g3,cc,cd="",ab(),aE==0 and ab()local H;local function g4(g5)if g5 then if g3 then local aP=0;if g3~=""and#g3+#g5>=bx then aP=bx-#g3;ag(cc,cd,g3 ..f(g5,1,aP),0,bx,bx)g3=""end;local aK=#g5-aP;local g6=aK%bx;ag(cc,cd,g5,aP,aK-g6,bx)g3=g3 ..f(g5,#g5+1-g6)return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if g3 then local gg=gf and 31 or 6;g3=g3 ..(#g3+1==bx and d(gg+128)or d(gg)..e("\0",(-2-#g3)%bx).."\128")ag(cc,cd,g3,0,#g3,bx)g3=nil;local gh=0;local gi=j(bx/8)local gj={}local function gk(bz)if gh>=gi then ag(cc,cd,"\0\0\0\0\0\0\0\0",0,8,8)gh=0 end;bz=j(l(bz,gi-gh))if aE~=0 then for aM=1,bz do gj[aM]=aw(cc[gh+aM-1+ax])end else for aM=1,bz do gj[aM]=V(cd[gh+aM])..V(cc[gh+aM])end end;gh=gh+bz;return g(b(gj,"",1,bz),"(..)(..)(..)(..)(..)(..)(..)(..)","%8%7%6%5%4%3%2%1"),bz*8 end;local gl={}local gm,gn="",0;local function go(gp)gp=gp or 1;if gp<=gn then gn=gn-gp;local gq=gp*2;local H=f(gm,1,gq)gm=f(gm,gq+1)return H end;local gr=0;if gn>0 then gr=1;gl[gr]=gm;gp=gp-gn end;while gp>=8 do local gs,gt=gk(gp/8)gr=gr+1;gl[gr]=gs;gp=gp-gt end;if gp>0 then gm,gn=gk(1)gr=gr+1;gl[gr]=go(gp)else gm,gn="",0 end;return b(gl,"",1,gr)end;if ge<0 then H=go else H=go(ge)end end;return H end end;if g1 then return g4(g1)()else return g4 end end;local gu,gv,gw,gx;do function gu(gy)return g(gy,"%x%x",function(gz)return d(tonumber(gz,16))end)end;function gv(gA)return g(gA,".",function(aU)return i("%02x",c(aU))end)end;local gB={['+']=62,['-']=62,[62]='+',['/']=63,['_']=63,[63]='/',['=']=-1,['.']=-1,[-1]='='}local gC=0;for aM,gD in ipairs{'AZ','az','09'}do for gE=c(gD),c(gD,2)do local gF=d(gE)gB[gF]=gC;gB[gC]=gF;gC=gC+1 end end;function gw(gA)local H={}for aS=1,#gA,3 do local gG,gH,gI,gJ=c(f(gA,aS,aS+2)..'\0',1,-1)H[#H+1]=gB[j(gG/4)]..gB[gG%4*16+j(gH/16)]..gB[gI and gH%16*4+j(gI/64)or-1]..gB[gJ and gI%64 or-1]end;return b(H)end;function gx(gK)local H,gL={},3;for aS,gF in h(g(gK,'%s+',''),'()(.)')do local gM=gB[gF]if gM<0 then gL=gL-1;gM=0 end;local Z=aS%4;if Z>0 then H[-Z]=gM else local gG=H[-1]*4+j(H[-2]/16)local gH=H[-2]%16*16+j(H[-3]/4)local gI=H[-3]%4*64+gM;H[#H+1]=f(d(gG,gH,gI),1,gL)end end;return b(H)end end;local gN;local function gO(aO,fH,gP)return g(aO,".",function(aU)return d(W(c(aU),gP))end)..e(d(gP),fH-#aO)end;local function gQ(gR,gS,g1)local gT=gN[gR]if not gT then error("Unknown hash function",2)end;if#gS>gT then gS=gu(gR(gS))end;local gU=gR()(gO(gS,gT,0x36))local H;local function g4(g5)if not g5 then H=H or gR(gO(gS,gT,0x5C)..gu(gU()))return H elseif H then error("Adding more chunks is not allowed after receiving the result",2)else gU(g5)return g4 end end;if g1 then return g4(g1)()else return g4 end end;local function gV(gW,gX,co,cp)local gY=gX=="s"and 16 or 32;local gZ=#gW;if gZ>gY then error(i("For BLAKE2%s/BLAKE2%sp/BLAKE2X%s the 'salt' parameter length must not exceed %d bytes",gX,gX,gX,gY),2)end;if co then local g_,h0,h1=0,gX=="s"and 4 or 8,gX=="s"and O or aa;for aM=5,4+k(gZ/h0)do local h2,h3;for I=1,h0,4 do g_=g_+4;local aT,E,aU,aV=c(gW,g_-3,g_)local h4=(((aV or 0)*256+(aU or 0))*256+(E or 0))*256+(aT or 0)h2,h3=h3,h4 end;co[aM]=h1(co[aM],h2 and h3*aD+h2 or h3)if cp then cp[aM]=h1(cp[aM],h3)end end end end;local function h5(g1,gS,gW,ge,h6,h7)ge=ge or 32;if ge<1 or ge>32 then error("BLAKE2s digest length must be from 1 to 32 bytes",2)end;gS=gS or""local h8=#gS;if h8>32 then error("BLAKE2s key length must not exceed 32 bytes",2)end;gW=gW or""local bj,g3,aN=0.0,"",{unpack(an)}if h7 then aN[1]=O(aN[1],ge)aN[2]=O(aN[2],0x20)aN[3]=O(aN[3],h7)aN[4]=O(aN[4],0x20000000+h6)else aN[1]=O(aN[1],0x01010000+h8*256+ge)if h6 then aN[4]=O(aN[4],h6)end end;if gW~=""then gV(gW,"s",aN)end;local function g4(g5)if g5 then if g3 then local aP=0;if g3~=""and#g3+#g5>64 then aP=64-#g3;bj=ah(aN,g3 ..f(g5,1,aP),0,64,bj)g3=""end;local aK=#g5-aP;local g6=aK>0 and(aK-1)%64+1 or 0;bj=ah(aN,g5,aP,aK-g6,bj)g3=g3 ..f(g5,#g5+1-g6)return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if g3 then if h7 then ah(aN,nil,0,64,0,32)else ah(aN,g3 ..e("\0",64-#g3),0,64,bj,#g3)end;g3=nil;if not h6 or h7 then local g8=k(ge/4)for aM=1,g8 do aN[aM]=V(aN[aM])end;aN=f(g(b(aN,"",1,g8),"(..)(..)(..)(..)","%4%3%2%1"),1,ge*2)end end;return aN end end;if h8>0 then g4(gS..e("\0",64-h8))end;if h7 then return g4()elseif g1 then return g4(g1)()else return g4 end end;local function h9(g1,gS,gW,ge,h6,h7)ge=j(ge or 64)if ge<1 or ge>64 then error("BLAKE2b digest length must be from 1 to 64 bytes",2)end;gS=gS or""local h8=#gS;if h8>64 then error("BLAKE2b key length must not exceed 64 bytes",2)end;gW=gW or""local bj,g3,co,cp=0.0,"",{unpack(am)},not aw and{unpack(an)}if h7 then if cp then co[1]=aa(co[1],ge)cp[1]=aa(cp[1],0x40)co[2]=aa(co[2],h7)cp[2]=aa(cp[2],h6)else co[1]=aa(co[1],0x40*aD+ge)co[2]=aa(co[2],h6*aD+h7)end;co[3]=aa(co[3],0x4000)else co[1]=aa(co[1],0x01010000+h8*256+ge)if h6 then if cp then cp[2]=aa(cp[2],h6)else co[2]=aa(co[2],h6*aD)end end end;if gW~=""then gV(gW,"b",co,cp)end;local function g4(g5)if g5 then if g3 then local aP=0;if g3~=""and#g3+#g5>128 then aP=128-#g3;bj=ai(co,cp,g3 ..f(g5,1,aP),0,128,bj)g3=""end;local aK=#g5-aP;local g6=aK>0 and(aK-1)%128+1 or 0;bj=ai(co,cp,g5,aP,aK-g6,bj)g3=g3 ..f(g5,#g5+1-g6)return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if g3 then if h7 then ai(co,cp,nil,0,128,0,64)else ai(co,cp,g3 ..e("\0",128-#g3),0,128,bj,#g3)end;g3=nil;if h6 and not h7 then if cp then for aM=8,1,-1 do co[aM*2]=cp[aM]co[aM*2-1]=co[aM]end;return co,16 end else local g8=k(ge/8)if cp then for aM=1,g8 do co[aM]=V(cp[aM])..V(co[aM])end else for aM=1,g8 do co[aM]=aw(co[aM])end end;co=f(g(b(co,"",1,g8),"(..)(..)(..)(..)(..)(..)(..)(..)","%8%7%6%5%4%3%2%1"),1,ge*2)end;cp=nil end;return co end end;if h8>0 then g4(gS..e("\0",128-h8))end;if h7 then return g4()elseif g1 then return g4(g1)()else return g4 end end;local function ha(g1,gS,gW,ge)ge=ge or 32;if ge<1 or ge>32 then error("BLAKE2sp digest length must be from 1 to 32 bytes",2)end;gS=gS or""local h8=#gS;if h8>32 then error("BLAKE2sp key length must not exceed 32 bytes",2)end;gW=gW or""local hb,g2,hc,H={},0.0,0x02080000+h8*256+ge;for aM=1,8 do local bj,g3,aN=0.0,"",{unpack(an)}hb[aM]={bj,g3,aN}aN[1]=O(aN[1],hc)aN[3]=O(aN[3],aM-1)aN[4]=O(aN[4],0x20000000)if gW~=""then gV(gW,"s",aN)end end;local function g4(g5)if g5 then if hb then local hd=0;while true do local he=l(hd+64-g2%64,#g5)if he>hd then local hf=hb[j(g2/64)%8+1]local hg=f(g5,hd+1,he)g2,hd=g2+he-hd,he;local bj,g3=hf[1],hf[2]if#g3<64 then g3=g3 ..hg else local aN=hf[3]bj=ah(aN,g3,0,64,bj)g3=hg end;hf[1],hf[2]=bj,g3 else break end end;return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if hb then local hh={unpack(an)}hh[1]=O(hh[1],hc)hh[4]=O(hh[4],0x20010000)if gW~=""then gV(gW,"s",hh)end;for aM=1,8 do local hf=hb[aM]local bj,g3,aN=hf[1],hf[2],hf[3]ah(aN,g3 ..e("\0",64-#g3),0,64,bj,#g3,aM==8)if aM%2==0 then local hi=0;for q=aM-1,aM do local hf=hb[q]local aN=hf[3]for hj=1,8 do hi=hi+1;aA[hi]=aN[hj]end end;ah(hh,nil,0,64,64*(aM/2-1),aM==8 and 64,aM==8)end end;hb=nil;local g8=k(ge/4)for aM=1,g8 do hh[aM]=V(hh[aM])end;H=f(g(b(hh,"",1,g8),"(..)(..)(..)(..)","%4%3%2%1"),1,ge*2)end;return H end end;if h8>0 then gS=gS..e("\0",64-h8)for aM=1,8 do g4(gS)end end;if g1 then return g4(g1)()else return g4 end end;local function hk(g1,gS,gW,ge)ge=ge or 64;if ge<1 or ge>64 then error("BLAKE2bp digest length must be from 1 to 64 bytes",2)end;gS=gS or""local h8=#gS;if h8>64 then error("BLAKE2bp key length must not exceed 64 bytes",2)end;gW=gW or""local hb,g2,hc,H={},0.0,0x02040000+h8*256+ge;for aM=1,4 do local bj,g3,co,cp=0.0,"",{unpack(am)},not aw and{unpack(an)}hb[aM]={bj,g3,co,cp}co[1]=aa(co[1],hc)co[2]=aa(co[2],aM-1)co[3]=aa(co[3],0x4000)if gW~=""then gV(gW,"b",co,cp)end end;local function g4(g5)if g5 then if hb then local hd=0;while true do local he=l(hd+128-g2%128,#g5)if he>hd then local hf=hb[j(g2/128)%4+1]local hg=f(g5,hd+1,he)g2,hd=g2+he-hd,he;local bj,g3=hf[1],hf[2]if#g3<128 then g3=g3 ..hg else local co,cp=hf[3],hf[4]bj=ai(co,cp,g3,0,128,bj)g3=hg end;hf[1],hf[2]=bj,g3 else break end end;return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if hb then local hl,hm={unpack(am)},not aw and{unpack(an)}hl[1]=aa(hl[1],hc)hl[3]=aa(hl[3],0x4001)if gW~=""then gV(gW,"b",hl,hm)end;for aM=1,4 do local hf=hb[aM]local bj,g3,co,cp=hf[1],hf[2],hf[3],hf[4]ai(co,cp,g3 ..e("\0",128-#g3),0,128,bj,#g3,aM==4)if aM%2==0 then local hi=0;for q=aM-1,aM do local hf=hb[q]local co,cp=hf[3],hf[4]for hj=1,8 do hi=hi+1;az[hi]=co[hj]if cp then hi=hi+1;az[hi]=cp[hj]end end end;ai(hl,hm,nil,0,128,128*(aM/2-1),aM==4 and 128,aM==4)end end;hb=nil;local g8=k(ge/8)if aw then for aM=1,g8 do hl[aM]=aw(hl[aM])end else for aM=1,g8 do hl[aM]=V(hm[aM])..V(hl[aM])end end;H=f(g(b(hl,"",1,g8),"(..)(..)(..)(..)(..)(..)(..)(..)","%8%7%6%5%4%3%2%1"),1,ge*2)end;return H end end;if h8>0 then gS=gS..e("\0",128-h8)for aM=1,4 do g4(gS)end end;if g1 then return g4(g1)()else return g4 end end;local function hn(ho,hp,hq,gT,ge,g1,gS,gW)local hr,hs,ht=2^(gT/2)-1;if ge==-1 then ge=n;hs=j(hr)ht=true else if ge<0 then ge=-1.0*ge;ht=true end;hs=j(ge)if hs>=hr then error("Requested digest is too long.  BLAKE2X"..hp.." finite digest is limited by (2^"..j(gT/2)..")-2 bytes.  Hint: you can generate infinite digest.",2)end end;gW=gW or""if gW~=""then gV(gW,hp)end;local hu=ho(nil,gS,gW,nil,hs)local H;local function g4(g5)if g5 then if hu then hu(g5)return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if hu then local hv,hw=hu()hw,hu=hw or 8;local function hx(hy)local aK=l(gT,ge-hy*gT)if aK<=0 then return""end;for aM=1,hw do hq[aM]=hv[aM]end;for aM=hw+1,2*hw do hq[aM]=0 end;return ho(nil,nil,gW,aK,hs,j(hy))end;local hz={}if ht then local aS,hA,hB,hC=0,gT*2^32;local function go(hD,hE)if hD=="seek"then aS=hE%hA else local aK,hi=hD or 1,0;while aK>0 do local hF=aS%gT;local hy=(aS-hF)/gT;local hG=l(aK,gT-hF)if hB~=hy then hB=hy;hC=hx(hy)end;hi=hi+1;hz[hi]=f(hC,hF*2+1,(hF+hG)*2)aK=aK-hG;aS=(aS+hG)%hA end;return b(hz,"",1,hi)end end;H=go else for aM=1.0,k(ge/gT)do hz[aM]=hx(aM-1.0)end;H=b(hz)end end;return H end end;if g1 then return g4(g1)()else return g4 end end;local function hH(ge,g1,gS,gW)return hn(h5,"s",aA,32,ge,g1,gS,gW)end;local function hI(ge,g1,gS,gW)return hn(h9,"b",az,64,ge,g1,gS,gW)end;local function hJ(g1,gS,ge,hK,aR,hL)gS=gS or""ge=ge or 32;hK=hK or 0;if gS==""then aR=aR or an else local h8=#gS;if h8>32 then error("BLAKE3 key length must not exceed 32 bytes",2)end;gS=gS..e("\0",32-h8)aR={}for aM=1,8 do local aT,E,aU,aV=c(gS,4*aM-3,4*aM)aR[aM]=((aV*256+aU)*256+E)*256+aT end;hK=hK+16 end;local g3,aN,d2,hM,hN,hO="",{},0,0,0,{}local hP,hQ,ht,H,d5=aR;local hR=3;local function hS(aO,aP,aK)while aK>0 do local hT,hU,d3=1,0,aN;if hM==0 then hU=1;d3,hP=aR,aN;hR=2 elseif hM==15 then hU=2;hR=3;hP=aR else hT=l(aK/64,15-hM)end;local hG=hT*64;aj(aO,aP,hG,hK+hU,d2,d3,aN)aP,aK=aP+hG,aK-hG;hM=(hM+hT)%16;if hM==0 then d2=d2+1.0;local hV=2.0;while d2%hV==0 do hV=hV*2.0;hN=hN-8;for aM=1,8 do aA[aM]=hO[hN+aM]end;for aM=1,8 do aA[aM+8]=aN[aM]end;aj(nil,0,64,hK+4,0,aR,aN)end;for aM=1,8 do hO[hN+aM]=aN[aM]end;hN=hN+8 end end end;local function hx(hy)local aK=l(64,ge-hy*64)if hy<0 or aK<=0 then return""end;if ht then for aM=1,16 do aA[aM]=hO[aM+16]end end;aj(nil,0,64,hR,hy,hP,hO,d5,hQ)if hL then return hO end;local g8=k(aK/4)for aM=1,g8 do hO[aM]=V(hO[aM])end;return f(g(b(hO,"",1,g8),"(..)(..)(..)(..)","%4%3%2%1"),1,aK*2)end;local function g4(g5)if g5 then if g3 then local aP=0;if g3~=""and#g3+#g5>64 then aP=64-#g3;hS(g3 ..f(g5,1,aP),0,64)g3=""end;local aK=#g5-aP;local g6=aK>0 and(aK-1)%64+1 or 0;hS(g5,aP,aK-g6)g3=g3 ..f(g5,#g5+1-g6)return g4 else error("Adding more chunks is not allowed after receiving the result",2)end else if g3 then hQ=#g3;g3=g3 ..e("\0",64-#g3)if aA[0]then for aM=1,16 do local aT,E,aU,aV=c(g3,4*aM-3,4*aM)aA[aM]=N(P(aV,24),P(aU,16),P(E,8),aT)end else for aM=1,16 do local aT,E,aU,aV=c(g3,4*aM-3,4*aM)aA[aM]=((aV*256+aU)*256+E)*256+aT end end;g3=nil;for hN=hN-8,0,-8 do aj(nil,0,64,hK+hR,d2,hP,aN,nil,hQ)d2,hQ,hP,hR=0,64,aR,4;for aM=1,8 do aA[aM]=hO[hN+aM]end;for aM=1,8 do aA[aM+8]=aN[aM]end end;hR=hK+hR+8;if ge<0 then if ge==-1 then ge=n else ge=-1.0*ge end;ht=true;for aM=1,16 do hO[aM+16]=aA[aM]end end;ge=l(2^53,ge)d5=ge>32;if ht then local aS,hB,hC=0.0;local function go(hD,hE)if hD=="seek"then aS=hE*1.0 else local aK,hi=hD or 1,32;while aK>0 do local hF=aS%64;local hy=(aS-hF)/64;local hG=l(aK,64-hF)if hB~=hy then hB=hy;hC=hx(hy)end;hi=hi+1;hO[hi]=f(hC,hF*2+1,(hF+hG)*2)aK=aK-hG;aS=aS+hG end;return b(hO,"",33,hi)end end;H=go elseif ge<=64 then H=hx(0)else local hW=k(ge/64)-1;for hy=0.0,hW do hO[33+hy]=hx(hy)end;H=b(hO,"",33,33+hW)end end;return H end end;if g1 then return g4(g1)()else return g4 end end;local function hX(hY,hZ,h_)if type(hZ)~="string"then error("'context_string' parameter must be a Lua string",2)end;local aR=hJ(hZ,nil,nil,32,nil,true)return hJ(hY,nil,h_,64,aR)end;local i0={md5=ga,sha1=gc,sha224=function(g1)return g0(224,g1)end,sha256=function(g1)return g0(256,g1)end,sha512_224=function(g1)return g9(224,g1)end,sha512_256=function(g1)return g9(256,g1)end,sha384=function(g1)return g9(384,g1)end,sha512=function(g1)return g9(512,g1)end,sha3_224=function(g1)return gd((1600-2*224)/8,224/8,false,g1)end,sha3_256=function(g1)return gd((1600-2*256)/8,256/8,false,g1)end,sha3_384=function(g1)return gd((1600-2*384)/8,384/8,false,g1)end,sha3_512=function(g1)return gd((1600-2*512)/8,512/8,false,g1)end,shake128=function(ge,g1)return gd((1600-2*128)/8,ge,true,g1)end,shake256=function(ge,g1)return gd((1600-2*256)/8,ge,true,g1)end,hmac=gQ,hex_to_bin=gu,bin_to_hex=gv,base64_to_bin=gx,bin_to_base64=gw,hex2bin=gu,bin2hex=gv,base642bin=gx,bin2base64=gw,blake2b=h9,blake2s=h5,blake2bp=hk,blake2sp=ha,blake2xb=hI,blake2xs=hH,blake2=h9,blake2b_160=function(g1,gS,gW)return h9(g1,gS,gW,20)end,blake2b_256=function(g1,gS,gW)return h9(g1,gS,gW,32)end,blake2b_384=function(g1,gS,gW)return h9(g1,gS,gW,48)end,blake2b_512=h9,blake2s_128=function(g1,gS,gW)return h5(g1,gS,gW,16)end,blake2s_160=function(g1,gS,gW)return h5(g1,gS,gW,20)end,blake2s_224=function(g1,gS,gW)return h5(g1,gS,gW,28)end,blake2s_256=h5,blake3=hJ,blake3_derive_key=hX}gN={[i0.md5]=64,[i0.sha1]=64,[i0.sha224]=64,[i0.sha256]=64,[i0.sha512_224]=128,[i0.sha512_256]=128,[i0.sha384]=128,[i0.sha512]=128,[i0.sha3_224]=144,[i0.sha3_256]=136,[i0.sha3_384]=104,[i0.sha3_512]=72}return i0
