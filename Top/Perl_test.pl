open myfile,">","Mydata.txt";
foreach(1..200)
{
    my $a=int(rand(10000000));
    my $HEX=sprintf("%07x",$a);
    print myfile "$HEX\n";
}
