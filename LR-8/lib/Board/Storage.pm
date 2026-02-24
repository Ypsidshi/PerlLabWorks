package Board::Storage;
use strict;
use warnings;
use Exporter 'import';
use Fcntl ':flock';
use POSIX 'strftime';

our @EXPORT_OK = qw(read_ads append_ad search_ads);

sub _clean {
    my ($v) = @_;
    $v //= '';
    $v =~ s/\r?\n/ /g;
    $v =~ s/\t/ /g;
    $v =~ s/\s{2,}/ /g;
    $v =~ s/^\s+|\s+$//g;
    return $v;
}

sub read_ads {
    my ($file) = @_;
    open my $fh, '<', $file or return [];
    my @rows;
    my $is_header = 1;
    while (my $line = <$fh>) {
        chomp $line;
        next if $line eq '';
        if ($is_header) {
            $is_header = 0;
            next if $line =~ /^id\t/i;
        }
        my @f = split /\t/, $line, 8;
        my $row = {
            id          => $f[0] // '',
            title       => $f[1] // '',
            category    => $f[2] // '',
            price       => $f[3] // '',
            city        => $f[4] // '',
            contact     => $f[5] // '',
            description => $f[6] // '',
            date        => $f[7] // '',
        };
        push @rows, $row;
    }
    return \@rows;
}

sub append_ad {
    my ($file, $ad) = @_;
    my $id = strftime('%Y%m%d-', localtime) . sprintf('%03d', int(rand(1000)));
    my $date = strftime('%Y-%m-%d', localtime);
    my $line = join("\t",
        $id,
        _clean($ad->{title}),
        _clean($ad->{category}),
        _clean($ad->{price}),
        _clean($ad->{city}),
        _clean($ad->{contact}),
        _clean($ad->{description}),
        $date
    ) . "\n";

    open my $fh, '>>', $file or return (undef, "Не удалось открыть базу данных");
    flock $fh, LOCK_EX;
    print {$fh} $line;
    flock $fh, LOCK_UN;
    close $fh;
    return ($id, undef);
}

sub search_ads {
    my ($rows, $q, $category, $city) = @_;
    $q = _clean($q);
    $category = _clean($category);
    $city = _clean($city);

    my $q_re = $q ne '' ? qr/\Q$q\E/i : undef;
    my @out;
    for my $r (@$rows) {
        if ($category ne '' && lc($r->{category}) ne lc($category)) {
            next;
        }
        if ($city ne '' && lc($r->{city}) ne lc($city)) {
            next;
        }
        if ($q_re) {
            next unless (
                ($r->{title} // '') =~ $q_re ||
                ($r->{description} // '') =~ $q_re ||
                ($r->{city} // '') =~ $q_re
            );
        }
        push @out, $r;
    }
    return \@out;
}

1;
