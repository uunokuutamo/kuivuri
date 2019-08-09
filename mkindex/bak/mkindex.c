
#include <stdio.h>
#include <postgresql/libpq-fe.h>
#include <string.h>
#include <stdlib.h>
#include "gnuplot_i.h"
#include <ftplib.h>

int upload2ftp(void);
 
int main() {	
	int row;
//	int col;
	int rec_count;
	PGconn          *conn;
	PGresult        *res;
	PGresult        *avg10;
	PGresult        *avg30;
	PGresult        *avg60;
	PGresult        *avg720;
	PGresult        *avg1440;
	PGresult        *lasttimestamp;
	
	char title1[100];
	char pagetitle[100];
	
//	chdir("/tmp");
	
	FILE *fp1 = fopen("lammot10.tsv", "w+");
	FILE *fp2 = fopen("lammot30.tsv", "w+");
	FILE *fp3 = fopen("lammot60.tsv", "w+");
	FILE *fp4 = fopen("lammot720.tsv", "w+");
	FILE *fp5 = fopen("lammot1440.tsv", "w+");
	FILE *idx = fopen("index.html", "w+");		

	conn = PQconnectdb("dbname=kuivuri host=192.168.1.80 user=dt password=dt");
 
	if (PQstatus(conn) == CONNECTION_BAD) {
		puts("We were unable to connect to the database");
		exit(0);
	}
 
 	// res = PQexec(conn, "select row_number() over(), ulko, meno, paluu from viim10 order by ts desc");
 	res = PQexec(conn, "select hhmm, ulko, meno, paluu from viim10c order by ts desc");
    
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
		puts("We did not get any data from viim10!");
		exit(0);
}
	rec_count = PQntuples(res);        

	for (row=0; row<rec_count; row++) {
		fprintf(fp1, "%s", PQgetvalue(res, row, 0));
		fprintf(fp1, "\t%s", PQgetvalue(res, row, 1));
		fprintf(fp1, "\t%s", PQgetvalue(res, row, 2));
		fprintf(fp1, "\t%s", PQgetvalue(res, row, 3));
		fprintf(fp1,"\n");        
	}
	fclose( fp1 );
 
	res = PQexec(conn, "select hhmm, ulko, meno, paluu from viim30c order by ts desc");
            
	if (PQresultStatus(res) != PGRES_TUPLES_OK) {
		puts("We did not get any data from viim30!");
		exit(0);
}
	rec_count = PQntuples(res);        
      

	for (row=0; row<rec_count; row++) {
		fprintf(fp2, "%s", PQgetvalue(res, row, 0));
		fprintf(fp2, "\t%s", PQgetvalue(res, row, 1));
		fprintf(fp2, "\t%s", PQgetvalue(res, row, 2));
		fprintf(fp2, "\t%s", PQgetvalue(res, row, 3));
		fprintf(fp2,"\n");        
	}	
	fclose( fp2 );


	
	res = PQexec(conn, "select hhmm, ulko, meno, paluu from viim60c order by ts desc");
         
	if (PQresultStatus(res) != PGRES_TUPLES_OK) {
		puts("We did not get any data from viim60!");
		exit(0);
}
	rec_count = PQntuples(res);        
      
	for (row=0; row<rec_count; row++) {

		fprintf(fp3, "%s", PQgetvalue(res, row, 0));
		fprintf(fp3, "\t%s", PQgetvalue(res, row, 1));
		fprintf(fp3, "\t%s", PQgetvalue(res, row, 2));
		fprintf(fp3, "\t%s", PQgetvalue(res, row, 3));
		fprintf(fp3,"\n");        
	}	
	fclose( fp3 );

	
	
	res = PQexec(conn, "select hhmm, ulko, meno, paluu from viim720c order by ts desc");
         
	if (PQresultStatus(res) != PGRES_TUPLES_OK) {
		puts("We did not get any data from viim720!");
		exit(0);
}
	rec_count = PQntuples(res);        

	for (row=0; row<rec_count; row++) {
		fprintf(fp4, "%s", PQgetvalue(res, row, 0));
		fprintf(fp4, "\t%s", PQgetvalue(res, row, 1));
		fprintf(fp4, "\t%s", PQgetvalue(res, row, 2));
		fprintf(fp4, "\t%s", PQgetvalue(res, row, 3));
		fprintf(fp4,"\n");        
	}
	fclose( fp4 );
	
	res = PQexec(conn, "select hhmm, ulko, meno, paluu from viim1440c order by ts desc");
         
	if (PQresultStatus(res) != PGRES_TUPLES_OK) {
		puts("We did not get any data from viim1440!");
		exit(0);
}
	rec_count = PQntuples(res);        
      
	for (row=0; row<rec_count; row++) {
		fprintf(fp5, "%s", PQgetvalue(res, row, 0));
		fprintf(fp5, "\t%s", PQgetvalue(res, row, 1));
		fprintf(fp5, "\t%s", PQgetvalue(res, row, 2));
		fprintf(fp5, "\t%s", PQgetvalue(res, row, 3));
		fprintf(fp5,"\n");        
	}
	fclose( fp5 );

	
	char *average10[5];
	char *average30[5];
	char *average60[5];
	char *average720[5];
	char *average1440[5];
	
	avg10 = PQexec(conn, "select * from avg10, continuous(10), slope(10)");
	avg30 = PQexec(conn, "select * from avg30, continuous(30), slope(30)");
	avg60 = PQexec(conn, "select * from avg60, continuous(60), slope(60)");
	avg720 = PQexec(conn, "select * from avg720, continuous(120), slope(120)");
	avg1440 = PQexec(conn, "select * from avg1440, continuous(300), slope(300)");
	
	rec_count = PQntuples(avg10); 
	if (PQresultStatus(avg10) != PGRES_TUPLES_OK) {
		puts("We did not get any data from avg10!");
		exit(0);
	}
	
	int r;
	for ( r=0; r < 5; r++) {
		average10[r] = PQgetvalue(avg10, 0, r);
		average30[r] = PQgetvalue(avg30, 0, r);
		average60[r] = PQgetvalue(avg60, 0, r);
		average720[r] = PQgetvalue(avg720, 0, r);
		average1440[r] = PQgetvalue(avg1440, 0, r);
	}
	
	
	
	res = PQexec(conn, "select * from avg30");
	
	if (PQresultStatus(res) != PGRES_TUPLES_OK) {
		puts("We did not get any data from avg30!");
		exit(0);
	}
	
	lasttimestamp = PQexec(conn, "select max(ts) from temp");
	sprintf(pagetitle, "%s", PQgetvalue(lasttimestamp,0, 0));
	
	
	PQclear(res);
	PQfinish(conn); 
	
    gnuplot_ctrl * h0 ;
    h0 = gnuplot_init() ;
    gnuplot_set_xlabel(h0, "Viimeiset 10 minuuttia") ;
    gnuplot_cmd(h0, "set terminal png size 800,480") ;
    gnuplot_cmd(h0, "set output \"viim10.png\"") ;
    gnuplot_cmd(h0, "set xdata time") ;
    gnuplot_cmd(h0, "set timefmt \"%Y%m%d%H:%M\"") ;
//    gnuplot_cmd(h0, "set timefmt \"%Y-%m-%d-%H:%M\"") ;
    gnuplot_cmd(h0, "set format x \"%H:%M\"") ;
//	gnuplot_cmd(h0, "set xrange [\"2017-09-09 10:00:00\":\"2017-09-09 11:20:00\"]");    
	gnuplot_cmd(h0, "set grid") ;
    gnuplot_cmd(h0, "plot \"lammot10.tsv\" u 1:2 w l t \"Ulkoilma\", \"lammot10.tsv\" u 1:3 w l t \"Menoilma\", \"lammot10.tsv\" u 1:4 w l t \"Poistoilma\" ");
  gnuplot_cmd(h0, "show timefmt");    
gnuplot_close(h0) ;
	puts("EKA");
	
    gnuplot_ctrl * h1 ;
    h1 = gnuplot_init() ;
    gnuplot_set_xlabel(h1, "Viimeiset 30 minuuttia") ;
    gnuplot_cmd(h1, "set terminal png size 800,480") ;
    gnuplot_cmd(h1, "set output \"viim30.png\"") ;
    gnuplot_cmd(h1, "set xdata time") ;
    gnuplot_cmd(h1, "set timefmt \"%Y-%m-%d-%H:%M\"") ;
    gnuplot_cmd(h1, "set format x \"%H:%M\"") ;
    gnuplot_cmd(h1, "set grid") ;
    gnuplot_cmd(h1, "plot \"lammot30.tsv\" u 1:2 w l t \"Ulkoilma\", \"lammot30.tsv\" u 1:3 w l t \"Menoilma\", \"lammot30.tsv\" u 1:4 w l t \"Poistoilma\" ");
    gnuplot_close(h1) ;
    
    gnuplot_ctrl * h2 ;
    h2 = gnuplot_init() ;
    gnuplot_set_xlabel(h2, "Viimeiset 60 minuuttia") ;
    gnuplot_cmd(h2, "set terminal png size 800,480") ;
    gnuplot_cmd(h2, "set output \"viim60.png\"") ;
    gnuplot_cmd(h2, "set xdata time") ;
    gnuplot_cmd(h2, "set timefmt \"%Y-%m-%d-%H:%M\"") ;
    gnuplot_cmd(h2, "set format x \"%H:%M\"") ;
    gnuplot_cmd(h2, "set grid") ;
    gnuplot_cmd(h2, "plot \"lammot60.tsv\" u 1:2 w l t \"Ulkoilma\", \"lammot60.tsv\" u 1:3 w l t \"Menoilma\", \"lammot60.tsv\" u 1:4 w l t \"Poistoilma\" ");
    gnuplot_close(h2) ;

    gnuplot_ctrl * h3 ;
    h3 = gnuplot_init() ;
    gnuplot_set_xlabel(h3, "Viimeiset kuusi tuntia") ;  
    gnuplot_cmd(h3, "set terminal png size 800,480") ;
    gnuplot_cmd(h3, "set output \"viim720.png\"") ;
    gnuplot_cmd(h3, "set xdata time") ;
    gnuplot_cmd(h3, "set timefmt \"%Y-%m-%d-%H:%M\"") ;
    gnuplot_cmd(h3, "set format x \"%H:%M\"") ;
    gnuplot_cmd(h3, "set grid") ;
    gnuplot_cmd(h3, "plot \"lammot720.tsv\" u 1:2 w l t \"Ulkoilma\", \"lammot720.tsv\" u 1:3 w l t \"Menoilma\", \"lammot720.tsv\" u 1:4 w l t \"Poistoilma\" ");
    gnuplot_close(h3) ;

    gnuplot_ctrl * h4 ;
    h4 = gnuplot_init() ;
    gnuplot_set_xlabel(h4, "Viimeiset 24 tuntia") ;
    gnuplot_cmd(h4, "set terminal png size 800,480") ;
    gnuplot_cmd(h4, "set output \"viim1440.png\"") ;
    gnuplot_cmd(h4, "set xdata time") ;
    gnuplot_cmd(h4, "set timefmt \"%Y-%m-%d-%H:%M\"") ;
    gnuplot_cmd(h4, "set format x \"%H:%M\"") ;
    gnuplot_cmd(h4, "set grid") ;
    gnuplot_cmd(h4, "plot \"lammot1440.tsv\" u 1:2 w l t \"Ulkoilma\", \"lammot1440.tsv\" u 1:3 w l t \"Menoilma\", \"lammot1440.tsv\" u 1:4 w l t \"Poistoilma\" ");
    gnuplot_close(h4) ;
    
    
	fprintf(idx, "<HTML xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\"><HEAD>\n");
	fprintf(idx, "<meta http-equiv=\"refresh\" content=\"60\"/>");
	fprintf(idx, "<STYLE rel=\"stylesheet\" type=\"text/css\">");
	fprintf(idx, "body { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; }");	
	fprintf(idx, "TABLE { align: center; margin-left: auto; margin-right: auto; }");	
	fprintf(idx, "TD { vertical-align: center; horizontal-align: center; padding: 5px;}");		
	fprintf(idx, "TH { font-weight: bold; padding: 5px;}");	
	fprintf(idx, "H1 { text-align: center;}");			
	fprintf(idx, "</STYLE>");	
	
	fprintf(idx, "<TITLE>Kuivurin dataa</TITLE></HEAD>\n");
	// fprintf(idx, "<basefont face=\"verdana, arial\">"); 
	fprintf(idx, "<BODY>\n"); 
	fprintf(idx, "<H1>%s</H1>\n", pagetitle); 
	
	fprintf(idx, "<TABLE BORDER=2 WIDTH=95%>");
	fprintf(idx, "<TR><TD>");
	
	fprintf(idx, "<img src=\"viim10.png\">\n");
	fprintf(idx, "</TD><TD>");
	
	fprintf(idx, "<TABLE BORDER=\"1\">");
	fprintf(idx, "<TR>");
	fprintf(idx, "<TH>Aika</TH>");
	fprintf(idx, "<TH>Ulkoilma</TH>");
	fprintf(idx, "<TH>Menoilma</TH>");
	fprintf(idx, "<TH>Poistoilma</TH>");
	fprintf(idx, "<TH>Jatkuvuus</TH>");
	fprintf(idx, "<TH>Kehitys 60 minuutin ajalta</TH><TR>");	
	fprintf(idx, "<TD>10 min</TD>");
	int j;	
	for( j = 0; j < 5 ; j++) {
		fprintf(idx, "<TD>%s</TD> " ,average10[j]);
	}
	fprintf(idx, "</TR><TR>");
	
	fprintf(idx, "<TD>30 min</TD>");
	for( j = 0; j < 5 ; j++) {
		fprintf(idx, "<TD>%s</TD> " ,average30[j]);
	}
	
	fprintf(idx, "</TR><TR>");
	fprintf(idx, "<TD>60 min</TD>");
	for( j = 0; j < 5 ; j++) {
		fprintf(idx, "<TD>%s</TD> " ,average60[j]);
	}
	fprintf(idx, "</TR><TR>");
	fprintf(idx, "<TD>720 min</TD>");
	for( j = 0; j < 5 ; j++) {
		fprintf(idx, "<TD>%s</TD> " ,average720[j]);
	}
	fprintf(idx, "</TR><TR>");
	fprintf(idx, "<TD>1440 min</TD>");
	for( j = 0; j < 5 ; j++) {
		fprintf(idx, "<TD>%s</TD> " ,average1440[j]);
	}
	fprintf(idx, "</TR>");
	fprintf(idx, "</TABLE>");
	fprintf(idx, "</TD></TR>");
	fprintf(idx, "<TR><TD>");
	fprintf(idx, "<img src=\"viim30.png\">\n");
	fprintf(idx, "</TD><TD>");
	fprintf(idx, "</TD></TR>");
	fprintf(idx, "</TD></TR>");
	fprintf(idx, "<TR><TD>");
	fprintf(idx, "<img src=\"viim60.png\">\n");
	fprintf(idx, "</TD><TD>");
	fprintf(idx, "</TD></TR>");
	fprintf(idx, "<TR><TD>");
	fprintf(idx, "<img src=\"viim720.png\">\n");
	fprintf(idx, "</TD><TD>");
	fprintf(idx, "</TD></TR>");
	fprintf(idx, "<TR><TD>");
	fprintf(idx, "<img src=\"viim1440.png\">\n");
	fprintf(idx, "</TD><TD>");
	fprintf(idx, "</TD></TR>");
	fprintf(idx, "<TR><TD>");
	fprintf(idx, "</TD><TD>");
	fprintf(idx, "</TD></TR>");
	fprintf(idx, "</TABLE>\n");
	fprintf(idx, "</BODY></HTML>\n");
	fclose(idx);

upload2ftp();
return 0;
}

int upload2ftp(void) {
	char host[] = "www.savilampi.net";
	char user[] = "kuivuri";
	char pass[] = "Salasan1";

	const char *input1 = "viim10.png";
	const char *input2 = "viim30.png";
	const char *input3 = "viim60.png";
	const char *input4 = "viim720.png";
	const char *input5 = "viim1440.png";
	const char *indexfile = "index.html";
	static char modeI = 'I';
	static char modeA = 'A';
	int ret;
	int status = 0;
	static netbuf *nControl;
	
	
	FtpInit();
	ret = FtpConnect( host,  &nControl );
	if (ret == 1) {
		puts("Connected\n");
		status++;
	}
	else {
		printf("Not connected\n");
	}
	ret = FtpLogin(user, pass, nControl);

	if (ret == 1) {
		puts("Login OK\n");
		status++;
	}
	else {
		printf("Login failed\n");
	}
	
	ret = FtpOptions(FTPLIB_CONNMODE, FTPLIB_PASSIVE, nControl);
	if (ret == 1) {
		puts("Passive mode OK\n");
		status++;
	}
	else {
		printf("Passive mode failed\n");
	}
	
	ret = FtpPut(input1, input1, modeI, nControl);
		if (ret == 1) {
		puts("Picture 1 upload OK\n");
		status++;
	}
	else {
		printf("Picture 1 upload failed\n");
	}
	
	ret = FtpPut(input2, input2, modeI, nControl);
		if (ret == 1) {
		puts("Picture 2 upload OK\n");
		status++;
	}
	else {
		printf("Picture 2 upload failed\n");
	}
	ret = FtpPut(input3, input3, modeI, nControl);
			if (ret == 1) {
		puts("Picture 3 upload OK\n");
		status++;
	}
	else {
		printf("Picture 3 upload failed\n");
	}
	ret = FtpPut(input4, input4, modeI, nControl);
			if (ret == 1) {
		puts("Picture 4 upload OK\n");
		status++;
	}
	else {
		printf("Picture 4 upload failed\n");
	}

	ret = FtpPut(input5, input5, modeI, nControl);
			if (ret == 1) {
		puts("Picture 5 upload OK\n");
		status++;
	}
	else {
		printf("Picture 5 upload failed\n");
	}

	ret = FtpPut(indexfile, indexfile, modeA, nControl);
				if (ret == 1) {
		puts("Index.html upload OK\n");
		status++;
	}
	else {
		printf("Index.html upload failed\n");
	}

	if (status == 9) {
		puts("Process OK\n");
	}
	else {
		printf("Process failed\n");
	}


void FtpQuit(netbuf *nControl);

return(ret);
	
}

