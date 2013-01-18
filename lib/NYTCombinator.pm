package nyt;
use Dancer;
set serializer => 'JSON';
set logger => 'console';
set 'log' => 'debug';
set 'show_errors' => 1;
use XML::Simple;
use Data::Dumper;
use WWW::Mechanize;
use HTML::TreeBuilder;
use LWP;
use Template;
use Dancer::Plugin::Ajax;

our $VERSION = '0.1';

get '/' => sub {
  my $rss_feed = "http://www.nytimes.com/services/xml/rss/nyt/HomePage.xml";
  my %hash;
  my $browser= LWP::UserAgent->new();
  my $response = $browser->get($rss_feed);
  #getting the page contents
  my $xml_content = $response->content;
  #my $xml_content = get($rss_feed) or warn "Can't get XML page" / "\n";
  my $xml2 = XML::Simple->new(KeepRoot => 1);
  my $data = $xml2->XMLin($xml_content) or die "Parse Error\n";
  foreach my $item (@{$data->{rss}->{channel}->{item}}) {
    #  my @full_cont = ();
    my $title = $item->{title} . "\n";
    my $date = $item->{pubDate} . "\n";
    my $descrip = $item->{description} . "\n";
    my $link = $item->{link};
    $link =~ s{(\.html).*}{$1};
    push @{$hash{$title}}, $date, $descrip, $link;
  }
    template 'index.tt', { 'hash' => \%hash, };
};

#gets the content of the page(the article itself) with ajax
ajax '/getbody' => sub {
  my @full_cont = ();
  my $full_link = request->params->{link};
  $full_link = $full_link . "?pagewanted=all";
  my $m = WWW::Mechanize->new();
  $m->get($full_link);
  my $c = $m->content;
  #crawls the page for the div we want
  my $tree = HTML::TreeBuilder->new_from_content($c);
  for my $div ($tree->look_down(_tag => "div", class => "articleBody")) {
    my $body = $div->as_HTML();
    push(@full_cont, $body);
  }
  my $body = $full_cont[1]; 
  my %data = (content => $body);
  #sends the result as json
  my $json_text = to_json(\%data);
  $tree->delete();
  return $json_text
};

ajax '/getcomments' => sub {
	my %comment_list = ();
	my $comment_api='2618d5e23be49c1226361cbf16fea71a:3:67053910';
	my $base_uri_comment='http://api.nytimes.com/svc/community/v2/comments/url/exact-match.json?url=';
	my $url_comments = request->params->{url};
	$final_url_comments = uri_escape($url_comments);
	for ($count = 0; $count >= 500; $count + 25) {
		$comment_call = $base_uri_comment . $final_url_comments . '&[offset=' . $count . ']&api-key=' . $comment_api;
		my $browser_comments = LWP::UserAgent->new();
		my $comments = $browser->get($comment_call)->content;
		my %result = from_json($comments);
		%comment_list = (%comment_list, %result);
	}
	return %comment_list;
};

get '/popular' => sub {
  template 'popular.tt';
};
#gets the most popular results by sending a get request to the nyt API and using 
#//this information. Depending on which button you click on, sends a different ajax request<D-s>
ajax '/getshared' => sub {
  my $key = 'e795f9c7b0a33a86a62426f3f820576f:4:67053910';
  my $uri_shared =  'http://api.nytimes.com/svc/mostpopular/v2/mostshared/all-sections/';
  my $response = request->params->{type};
  if ($response == '1') {
    my $uri = $uri_shared . '1?api-key=' . $key;
    my $browser =  LWP::UserAgent->new();
	  my $response = $browser->get($uri)->content;    
    return $response;
  }
  if ($response == '7') {
    my $uri = $uri_shared . '7?api-key=' . $key;
    my $browser =  LWP::UserAgent->new();
	  my $response = $browser->get($uri)->content;  
    return $response;
  }
  if ($response == '30') {
    my $uri = $uri_shared . '30?api-key=' . $key;
    my $browser =  LWP::UserAgent->new();
    my $response = $browser->get($uri)->content;  
    return $response;
  }
};

true;
