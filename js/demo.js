
/*global SyntaxHighlighter*/
SyntaxHighlighter.config.tagName = 'code';

$(document).ready( function () {
	// Work around for WebKit bug 55740
	var info = $('div.info');

	if ( info.height() < 158 ) {
		info.css( 'height', '11em' );
	}

	var escapeHtml = function ( str ) {
		return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
	};

	// css
	var cssContainer = $('div.tabs div.css');
	if ( $.trim( cssContainer.find('code').text() ) === '' ) {
		cssContainer.find('code, p:eq(0), div').css('display', 'none');
	}

	// init html
	var table = $('<p/>').append( $('table').clone() ).html();
	$('div.tabs div.table').append(
		'<code class="multiline brush: html;">\t\t\t'+
			escapeHtml( table )+
		'</code>'
	);
	//SyntaxHighlighter.highlight({}, $('#display-init-html')[0]);

	// json
	var ajaxTab = $('ul.tabs li').eq(3).css('display', 'none');

	$(document).on( 'init.dt', function ( e, settings ) {
		var api = new $.fn.dataTable.Api( settings );

		var show = function ( str ) {
			ajaxTab.css( 'display', 'block' );
			$('div.tabs div.ajax code').remove();

			// Old IE :-|
			try {
				str = JSON.stringify( str, null, 2 );
			} catch ( e ) {}

			$('div.tabs div.ajax').append(
				'<code class="multiline brush: js;">'+str+'</code>'
			);
			SyntaxHighlighter.highlight( {}, $('div.tabs div.ajax code')[0] );
		};

		// First draw
		var json = api.ajax.json();
		if ( json ) {
			show( json );
		}

		// Subsequent draws
		api.on( 'xhr.dt', function ( e, settings, json ) {
			show( json );
		} );
	} );

	// Tabs
	$('ul.tabs li').click( function () {
		$('ul.tabs li.active').removeClass('active');
		$(this).addClass('active');

		$('div.tabs>div')
			.css('display', 'none')
			.eq( $(this).index() ).css('display', 'block');
	} );
	$('ul.tabs li.active').click();
} );
