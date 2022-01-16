import "topmenu.ash";

void main() {
	buffer results;
	results.append(visit_url());
	results.iconStyle();
	results.write();
}