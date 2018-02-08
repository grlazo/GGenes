#!/bin/bash
rsync -rlptovz -u -e ssh --exclude="nlui_report_bk/" --rsync-path=/opt/sfw/bin/rsync /home/hummel/graingenes/cgi-bin/ wheat:/home/www/cgi-bin/graingenes
rsync -rLptvz -u -e ssh --include="report_*.pl" --exclude="*" --exclude="*/" --rsync-path=/opt/sfw/bin/rsync wheat:/home/www/cgi-bin/graingenes/ /home/hummel/graingenes/cgi-bin/nlui_report_bk
