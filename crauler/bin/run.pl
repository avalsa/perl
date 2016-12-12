use FindBin;
use lib "$FindBin::Bin/../lib/";
use DDP;
use Local::Crauler;

my $c=Local::Crauler->new(url => 'https://habrahabr.ru'); 	#just example, also here params - limit, thread_cnt
$c->run;													#run main loop
