package nyt;
use Dancer;

use XML::Simple;
use Data::Dumper;
use WWW::Mechanize;
use HTML::TreeBuilder;
use LWP;
use Template;

our $VERSION = '0.1';

get '/' => sub {
  my $rss_feed = "http://www.nytimes.com/services/xml/rss/nyt/HomePage.xml";
  my %hash;
  my $browser= LWP::UserAgent->new();
  my $response = $browser->get($rss_feed);
  my $xml_content = $response->content;
  #my $xml_content = get($rss_feed) or warn "Can't get XML page" / "\n";
  my $xml2 = XML::Simple->new(KeepRoot => 1);
  my $data = $xml2->XMLin($xml_content) or die "Parse Error\n";
  foreach my $item (@{$data->{rss}->{channel}->{item}}) {
    my @full_cont = ();
    my $title = $item->{title} . "\n";
    my $date = $item->{pubDate} . "\n";
    my $descrip = $item->{description} . "\n";
    my $link = $item->{link};
    $link =~ s{(\.html).*}{$1};
    my $full_link = $link . "?pagewanted=all";
    my $m = WWW::Mechanize->new();
    $m->get($full_link);
    my $c = $m->content;
    my $tree = HTML::TreeBuilder->new_from_content($c);
    for my $div ($tree->look_down(_tag => "div", class => "articleBody")) {
      my $body = $div->as_HTML();
      push(@full_cont, $body);
    }
    my $actual_cont = $full_cont[1];
    push @{$hash{$title}}, $date, $descrip, $link, $actual_cont;
    $tree->delete();
  }
    template 'index.tt', { 'hash' => \%hash, };
};

true;
