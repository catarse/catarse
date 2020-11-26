import m, { VnodeDOM } from 'mithril'
import _ from 'underscore'
import Chart from 'chart.js'
import Stream from 'mithril/stream'

export default class ProjectDataChart {
    oninit(vnode) {
        vnode.state = {
            lastSource: []
        }
    }

    view({state, attrs}) {
        return _ProjectDataChart({ ...attrs, state })
    }
}

type ProjectDataChartProps = {
    label: string
    subLabel: string
    emptyState: string
    dataKey: string
    limitDataset: string | number
    collection: Stream<Resource[]>
    xAxis? : (item : Item) => string,
    state: {
        lastSource?: Item[]
    }
}

function _ProjectDataChart(props : ProjectDataChartProps) {
    const {
        label,
        subLabel,
        emptyState,
        dataKey,
        limitDataset,
        collection,
        xAxis,
        state
    } = props

    const source = extractSourceFrom(collection, limitDataset)

    function renderChartHoc(vnodeCanvas : VnodeDOM) {
        if (!_.isEqual(state.lastSource, source) || _.isEmpty(state.lastSource)) {
            renderChart(vnodeCanvas, source, dataKey, xAxis)
            state.lastSource = source
        }
    }

    return (
        <div className="card u-radius medium u-marginbottom-30">
            <div className="fontweight-semibold u-marginbottom-10 fontsize-large u-text-center">
                {label}
            </div>
            <div className="u-text-center fontsize-smaller fontcolor-secondary lineheight-tighter u-marginbottom-20">
                {subLabel || ''}
            </div>
            <div className="w-row">
                <div className="w-col w-col-12 overflow-auto">
                    {
                        !_.isEmpty(source) ?
                            <canvas oncreate={renderChartHoc} onupdate={renderChartHoc} id="chart" width="860" height="300"></canvas>
                            :
                            <div className="w-col w-col-8 w-col-push-2">
                                <p className="fontsize-base">
                                    {emptyState}
                                </p>
                            </div>
                    }
                </div>
            </div>
        </div>
    )
}

function extractSourceFrom(collection: Stream<Resource[]>, limitDataset: string | number) {
    const resource = _.first(collection())
    const source = !_.isUndefined(resource)
        ? _.isNumber(limitDataset)
            ? _.last(resource.source, limitDataset)
            : resource.source
        : []
    return source
}

function renderChart(vnodeCanvas : VnodeDOM, source : Item[], dataKey : string, xAxis? : (item : Item) => string) {
    const ctx = (vnodeCanvas.dom as HTMLCanvasElement).getContext('2d')
    // @ts-ignore
    new Chart(ctx).Line({
        labels: xAxis ? _.map(source, item => xAxis(item)) : [],
        datasets: mountDataset(source, dataKey)
    })
}

function mountDataset(source : Item[], dataKey : string) : DatasetMount {
    return [{
        fillColor: 'rgba(126,194,69,0.2)',
        strokeColor: 'rgba(126,194,69,1)',
        pointColor: 'rgba(126,194,69,1)',
        pointStrokeColor: '#fff',
        pointHighlightFill: '#fff',
        pointHighlightStroke: 'rgba(220,220,220,1)',
        data: _.map(source, item => item[dataKey])
    }]
}

type DatasetMount = [
    {
        fillColor: string
        strokeColor: string
        pointColor: string
        pointStrokeColor: string
        pointHighlightFill: string
        pointHighlightStroke: string
        data: string[]
    }
]

type Resource = {
    source: Item[]
}

type Item = any
