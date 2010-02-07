use 5.008;
use lib 'inc';
use ExtUtils::MakeMaker;
use Devel::CheckLib;

# Check for the dependencies we need to build
check_lib_or_exit( lib => 'nids', header => 'nids.h' );
check_lib_or_exit( lib => 'pcap', header => 'pcap.h' );

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::LibNIDS',
    'VERSION_FROM'	=> 'LibNIDS.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
#    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
#      (ABSTRACT_FROM => 'LibNIDS.pm', # retrieve abstract from module
#       AUTHOR     => 'Arthur Bergman <abergman@fotango.com>') : ()),
    'LIBS'		=> ['-lnids -lpcap'], # e.g., '-lm'
    'DEFINE'		=> '', # e.g., '-DHAVE_SOMETHING'
    'INC'		=> '-I.', # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
   # 'OBJECT'		=> '$(O_FILES)', # link all the C files too
);
if  (eval {require ExtUtils::Constant; 1}) {
  # If you edit these definitions to change the constants used by this module,
  # you will need to use the generated const-c.inc and const-xs.inc
  # files to replace their "fallback" counterparts before distributing your
  # changes.
  my @names = (qw(NIDS_CLOSE NIDS_DATA NIDS_EXITING NIDS_JUST_EST NIDS_MAJOR
		 NIDS_MINOR NIDS_RESET NIDS_TIMED_OUT));
  ExtUtils::Constant::WriteConstants(
                                     NAME         => 'Lib::nids',
                                     NAMES        => \@names,
                                     DEFAULT_TYPE => 'IV',
                                     C_FILE       => 'const-c.inc',
                                     XS_FILE      => 'const-xs.inc',
                                  );

}
else {
  use File::Copy;
  use File::Spec;
  foreach my $file ('const-c.inc', 'const-xs.inc') {
    my $fallback = File::Spec->catfile('fallback', $file);
    copy ($fallback, $file) or die "Can't copy $fallback to $file: $!";
  }
}
