# LDhcve.ctl: Collects HCVE Reports
# $Id: LDhcve.ctl,v 1.6 2015/04/29 14:12:58 RDA Exp $
# ARCS: $Header: /home/cvs/cvs/RDA_8/src/scripting/lib/collect/TOOL/LDhcve.ctl,v 1.6 2015/04/29 14:12:58 RDA Exp $
#
# Change History
# 20150424  MSC  Introduce the control agent concept.

=head1 NAME

TOOL:LDhcve - Collects HCVE Reports

=head1 DESCRIPTION

This module gets reports generated by the Health Check/Validation Engine.

The following report is produced:

=for stopwords hcve

=head2 hcve - Health Check/Validation Engine

Gets reports generated by the Health Check/Validation engine.

=cut

use Message

macro get_hcve_link
 return concat(basename($arg[0],'.txt'),'.htm')

debug ' Inside LOAD module, gathering HCVE reports'
report hcve
prefix
{write '---+ Health Check/Validation Results'
 write '|*Rule Set*|*Results*|*Errors*|'
}
var $pat = '<!-- Module:TSThcve Version:\S+ Report:(.*?) OS:'
var (%err,%res,%set) = ()
loop $fil (grepDir(${OUT.C},concat('^[A-Z][A-Z\d]*_HCVE_.*\.txt$'),'it'))
{if match($fil,'^([A-Z][A-Z\d]*)_HCVE_([A-Z])_(.*)_(err|man|res)\.txt$',true)
 {# Treat RDA 5 format
  var ($grp,$cls,$set,$typ) = last
  var $set = concat($grp,':',$cls,lc($set))
 }
 elsif match($fil,'_HCVE_(.*)_(err|man|res)\.txt$',true)
 {# Treat RDA 4 format
  var ($set,$typ) = last
  var $set = getSet(undef,s($set,'^([AP])\d{3}(.*)$','$1\L$2\E'))
  if exists($res{$set})
  {call purge('c',replace($fil,'txt$',''),0,0)
   next
  }
 }
 else
 {# Treat other file name formats
  var ($rpt) = grepFile(catFile(${OUT.C},$fil),$pat,'f1')
  if match($rpt,'^(res|err)$')
   var ($set,$typ) = ('?',last)
  else
   var ($typ,$set) = match($rpt,'^HCVE_(res|err)_(.*)$')
  if ?$set
   var $set = getSet(undef,$set)
 }

 # Store the report links
 if match($typ,'res',true)
  var $res{$set} = concat('[[',get_hcve_link($fil),'][_blank][results]]')
 elsif match($typ,'err',true)
  var $err{$set} = concat('[[',get_hcve_link($fil),'][_blank][errors]]')
}
var $off = {submitCommand('.',\
  'DIAGLET.DESCRIBE')->get_value('offsets')}->{'dsc'}
loop $set (keys(%res))
{var @dsc = submitCommand('.',\
   'DIAGLET.INFO',diaglet=>$set)->get_value('info')
 write '|',nvl($dsc[$off],$set),'|',$res{$set},' |',$err{$set},' |'
}
if isCreated(true)
{toc '0:      * [[',getFile(),'][rda_report][Health Check/Validation Engine]]'
 toc '2:[[',getFile(),'][rda_report][Health Check/Validation Engine]]'
}

=head1 COPYRIGHT NOTICE

Copyright (c) 2002, 2016, Oracle and/or its affiliates. All rights reserved.

=head1 TRADEMARK NOTICE

Oracle and Java are registered trademarks of Oracle and/or its
affiliates. Other names may be trademarks of their respective owners.

=cut
