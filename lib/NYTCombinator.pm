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
use URI::Escape;

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
	my $url_comments = request->params->{url};
  my $find1 = ':';
  $find1 = quotemeta $find1;
  my $replace1 = '%253A';
  $url_comments =~ s/$find1/$replace1/g;
  my $find2 = '/';
  $find2 = quotemeta $find2;
  my $replace2 = '%252F';
  $url_comments =~ s/$find2/$replace2/g;
  my $offset=0; #Start off at the very beginning
  my $total_comments=1; #set a fake minimum number of contents
  my %comment_list=(); #Set up a place to store the results
  my @array = ();
  my $count = 0;
  while ($total_comments > $offset) {
      my $url='http://www.nytimes.com/svc/community/V3/requestHandler?callback=NYTD.commentsInstance.drawComments&method=get&cmd=GetCommentsAll&url=' . $url_comments . '&offset=' . $offset  . '&sort=newest'; #store the secret URL
      sleep(1);
      my $browser =  LWP::UserAgent->new();
      my $response = $browser->get($url)->content; 
      my $find = 'NYTD.commentsInstance.drawComments(';
      $find = quotemeta $find;
      $response =~ s/$find/""/g;
      my $substr = substr($response, 2, -2);
      my $json = new JSON;
      my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($substr);
      foreach my $comment(@{$json_text->{results}->{comments}}){
          $count += 1;
          print $count, "\n";
          my %comment_hash = ();
          $comment_hash{name} = $comment->{userID};
          $comment_hash{location} = $comment->{userLocation};
          $comment_hash{body} = $comment->{commentBody};
          push @array, \%comment_hash;
      }
      if ($substr =~ m/totalCommentsFound\":(.*?),/) {
          $total_comments =  $1;
      }
      $offset=$offset+25;
  }
  return @array;
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
