my @file=<*.v>;
open myfile,">","vflist";
for my $f(@file)
{
    print myfile "./$f\n";
}
close(myfile);
