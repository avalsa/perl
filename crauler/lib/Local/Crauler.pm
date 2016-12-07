package Local::Crauler;
use Mouse;
use AnyEvent::HTTP;
use AnyEvent;
use Web::Query;

has 'thread_cnt' => (is => 'rw', isa => 'Int', default => 16);
has 'url'  => (is => 'rw', isa => 'Str', required => 1);
has 'limit' => (is => 'rw', isa => 'Int', default => 50);

my @to_procede; 	#urls that were found
my %done;  			#key = url, value = it's size

sub BUILD{
	my $self=shift;
	$AnyEvent::HTTP::MAX_PER_HOST = $self->thread_cnt;		#to load data more than in 4 threads
	push @to_procede, $self->url;
}

sub logger{
	my ($self, $msg)=@_;
	print $msg . "\n";
}

sub _do_work{
	my ($self, $cb, $adr)=@_;
	if (exists($done{$adr})){ 		#if have so not need yet
		$cb->();
		return;
	}
	$done{$adr}=-1;					#mark it for if some another thread want to begin load, stop it  
	my $w; $w = http_request GET => $adr, sub {
    	my ($body, $hdr) = @_;
    	unless (defined $body and defined $hdr){
    		$cb->();
			return;
    	}
    	my $len = $hdr->{'content-length'};
    	$done{$adr} = $len; 							#save new result	
    	my $q = Web::Query->new( $body );
		my @hrefs = $q->find('a')->attr('href');
		for my $href (@hrefs){
			if (defined($href) and index($href, $self->url) == 0){  	#same domain
				push @to_procede, $href unless(exists($done{$href})); 	#not procede yet
			}
		}
    	undef $w;
    	$self->logger("Processed $adr");
    	$cb->();
	};
	return;
}

sub run{
	my $self=shift;
	my $cv = AE::cv; $cv->begin;
	my $free = $self->thread_cnt;
	my $cur;
	my $next; $next = sub {
		my $n=keys %done;
		return if ($n >= $self->limit); #we achieved our goal
		return if ($free < 0);
		$free--;						#take resource
		$cur = pop @to_procede;
		return unless (defined $cur);
		$self->logger("Process $cur");
		$cv->begin;
		$self->_do_work(sub {
			$free++;					#free resource
			$next->();					#try to take one more (if have lack we will fall, 
			$next->();					#else with O(2^n) devisions will take all resources
			$cv->end;
		}, $cur);
	};
	$next->();
	$cv->end; $cv->recv;
	$self->_summary;
}

sub _summary{
	my $self=shift;
	my $sz=0;
	my @top;
	for my $key ( keys %done ) {
        my $value = $done{$key};
        $sz+=$value;
        if ($#top <10){ push @top, {key => $key, val => $value}; }
        else {
        	if ($top[0]<$value){
        		$top[0] = {key => $key, val => $value};
        		@top = sort {$a->val <=> $b->val} @top;
        	}
        }
        
    }
    print "TOTAL SIZE: $sz b\n";
    print "TOP 10:\n";
    for my $s (@top){
    	 print $s->{key} . "\n"; 
    }
}

1;
