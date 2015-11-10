$fileName = $ARGV[0];

open(LOG,"<". $fileName);

my $REMOTE_HOST;
my $FI;
my $REMOTE_USER;
my $DATE_TIME;
my $DATE_MONTH;
my $DATE_DAY;
my $DATE_YEAR;

my $DATE_HOUR;
my $DATE_MINUTE;
my $DATE_SEC;

my $METHOD;
my $REQUEST_URL;
my $HTTP_VERSION;
my $HTTP_RESPONSE;
my $DATA_BYTES;
my $REFERER;
my $USER_AGENT;

my($tLine)=0;
my @temp;
my @temp2;

while(<LOG>)
{
    /^(.*) (.*) (.*) \[(.*)\] "(.*)" (.*) (.*) "(.*)" "(.*)"$/;

    $REMOTE_HOST=$1;
    $FI=$2;
    $REMOTE_USER=$3;
    $DATE_TIME=$4;
    ($METHOD,$REQUEST_URL,$HTTP_VERSION)=split(/ /,$5);
    $HTTP_RESPONSE=$6;
    $DATA_BYTES=$7;
    $REFERER=$8;
    $USER_AGENT=$9;
    $USER_AGENT =~ s/,/ /g;

    @temp = split(/\//,$DATE_TIME);
    $DATE_DAY = $temp[0];
    $DATE_MONTH = convertMonth($temp[1]);

    @temp2 = split(/:/,$temp[2]);

    $DATE_YEAR = $temp2[0];
    $DATE_HOUR = $temp2[1];
    $DATE_MINUTE = $temp2[2];
    ($DATE_SEC,$GMT)=split(/ /,$temp2[3]);

    $PART_DATE =  $DATE_YEAR ."/" . $DATE_MONTH ."/" . $DATE_DAY;
    $PART_MIN=  $DATE_HOUR .":" . $DATE_MINUTE .":" . $DATE_SEC;

    print $PART_DATE . "," . $PART_MIN . "," . $REMOTE_HOST . "," . $FI . "," . $REMOTE_USER . "," .  $METHOD . "," . $REQUEST_URL . "," . $HTTP_RESPONSE . "," . $DATA_BYTES . "," . $REFERER . "," . $USER_AGENT ."\n";

    $tLine++;
}


sub convertMonth {

  my ($targetMonth) = @_;

  my $convertMonth;

  if ($targetMonth eq "Jun") {
        $convertMonth = "01";
  } elsif ($targetMonth eq "Feb") {
        $convertMonth = "02";
  } elsif ($targetMonth eq "Mar") {
        $convertMonth = "03";
  } elsif ($targetMonth eq "Apr") {
        $convertMonth = "04";
  } elsif ($targetMonth eq "May") {
        $convertMonth = "05";
  } elsif ($targetMonth eq "Jun") {
        $convertMonth = "06";
  } elsif ($targetMonth eq "Jul") {
        $convertMonth = "07";
  } elsif ($targetMonth eq "Aug") {
        $convertMonth = "08";
  } elsif ($targetMonth eq "Sep") {
        $convertMonth = "09";
  } elsif ($targetMonth eq "Nov") {
        $convertMonth = "11";
  } elsif ($targetMonth eq "Dec") {
        $convertMonth = "12";
  }

  return $convertMonth;
}