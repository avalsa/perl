package Local::Crauler;
use Mouse;
use AnyEvent::HTTP;
use AnyEvent;
use Web::Query;
use Callback::Frame;
no warnings 'experimental';
has 'thread_cnt' => (is => 'rw', isa => 'Int', default => 16);
has 'url'  => (is => 'rw', isa => 'Str', required => 1);
has 'limit' => (is => 'rw', isa => 'Int', default => 50);
has '_to_procede' => (is => 'rw', isa => 'ArrayRef');
has '_done' => (is => 'rw', isa => 'HashRef');

sub BUILD{
	my $self=shift;
	$AnyEvent::HTTP::MAX_PER_HOST = $self->thread_cnt;		#to load data more than in 4 threads
	$self->_to_procede([]);
	$self->_done({});
	push $self->_to_procede, $self->url;
}

sub logger{
	my ($self, $msg)=@_;
	print $msg . "\n";
}

sub _do_work{
	my ($self, $cb, $adr)=@_;
	if (exists($self->_done->{$adr})){ 		#if have so not need yet
		$cb->();
		return;
	}
	$self->_done->{$adr}=-1;					#mark it for if some another thread want to begin load, stop it  
	frame_try {
		my $w; $w = http_request GET => $adr, fub {
			my ($body, $hdr) = @_;
			unless (defined $body and defined $hdr){
				undef $w;
				$cb->();
				return;
			}
    		#analize answer
    		if ($hdr->{'Status'}<200 or $hdr->{'Status'}>=400){		#if not 2xx or 3xx means something bad
    			undef $w;
    			$cb->();
    			return;
    		}
    		if ($hdr->{'Status'}>=300){
    			unless (index($hdr->{'URL'}, $self->url) == 0){ 	#redirect to another site
    				undef $w;
    				$cb->();
    				return;
    			}
    		}
    		########
    		my $len = $hdr->{'content-length'};
    		$self->_done->{$adr} = $len; 							#save new result	
    		my $q = Web::Query->new( $body );
    		my @hrefs = $q->find('a')->attr('href');
    		for my $href (@hrefs){
    			if (defined $href){
					$href = $hdr->{'URL'} . $href if ($href =~ m/^\/.+/);  #relative link (begins with /)
					if (index($href, $self->url) == 0){  	#same domain
						push $self->_to_procede, $href unless(exists($self->_done->{$href})); 
					}
				}
			}
			undef $w;
			$self->logger("Processed $adr");
			$cb->();
		};
	#return;
	} frame_catch {$self->logger("Error occured in GET"); $cb->();}
}

sub run{
	my $self=shift;
	my $cv = AE::cv; $cv->begin;
	my $free = $self->thread_cnt;
	my $cur;
	my $next; $next = sub {
		my $n=keys %{$self->_done};
		return if ($n >= $self->limit); #we achieved our goal
		return if ($free < 0);
		$free--;						#take resource
		$cur = pop $self->_to_procede;
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
	for my $key ( keys %{$self->_done} ) {
		my $value = $self->_done->{$key};
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
