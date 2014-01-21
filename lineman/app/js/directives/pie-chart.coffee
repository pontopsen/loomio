angular.module('loomioApp').directive 'pieChart', (d3Helpers) ->
	scope: { 'ngModel': '='}
	restrict: 'EA'
	require: 'ngModel'
	controller: 'ProposalController'
	link: (scope, element, attrs, ctrl) ->

		sizeChart = (proportion) ->
			cardWidth = element[0].clientWidth
			cardWidth * proportion

		##set attribute defaults and d3 method aliases
		w = attrs.width || sizeChart 1
		h = attrs.height || w
		r = attrs.radius || w/2
		arc = d3.svg.arc().innerRadius(0).outerRadius(r)
		pie = d3.layout.pie().value (d) -> d.count
		arcTween = (a) ->
    	i = d3.interpolate @._current, a
    	@._current = i 0
    	(t) ->
    		arc(i(t))

		## draw our base svg
		svg = d3.select(element[0])
		  .append('svg')
		  .attr('width', w)
		  .attr('height', h)
		  .attr('class', 'img-responsive')
		  .append('g')
		    .attr('id', 'arcs')
		    .attr('transform', 'translate('+r+','+r+')')

		## set piechart initial position at angle 0 if proposal.created_at < 3000ms
		initData = d3Helpers.setPieInitData scope.ngModel, pie

		## create arc objects with .data() instantiated with initData as placeholder
		arcs = svg.selectAll('path').data(initData, (d) -> d.type)
		  .enter().append('path')
		  .attr('d', arc)
		  .attr('class', (d) -> d.data.type)
		  .each((d) -> @._current = d)

		## watch for changes to proposal; make new array; make pie layout of array;
		## attach to arcs object; and transition old to new points
		scope.$watch 'ngModel', (updatedProposal, oldProposal) ->
			if updatedProposal
				d = d3Helpers.proposalArray updatedProposal
				arcs.data(pie(d), (d) -> d.type )
				  .transition().duration(750).ease('linear')
				  .attrTween('d', arcTween)

		scope.$watch scope.getScreenWidth, (newWidth) ->
			console.log newWidth



