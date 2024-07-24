import os
import argparse
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages


def calculate_ess(samples, burnin=0):
    """Calculate the effective sample size (ESS) of a set of samples."""
    samples = samples[burnin:]
    N = len(samples)
    mean = np.mean(samples)

    def autocorrelation(k):
        return np.sum((samples[: N - k] - mean) * (samples[k:] - mean)) / np.sum(
            (samples - mean) ** 2
        )

    # Autocorrelations
    autocorrs = np.array([autocorrelation(k) for k in range(1, N)])
    # Use only positive autocorrelations
    positive_autocorrs = autocorrs[autocorrs > 0]
    # Calculate the autocorrelation sum
    autocorr_sum = 1 + 2 * np.sum(positive_autocorrs)
    # Calculate ESS
    ess = N / autocorr_sum
    return ess


def report_descriptives(data, allcols, burnin, figsize, pdf):
    # Descriptive statistics
    allcols = ["state"] + cols

    # Plot the summy statistics as a table for inclusion in the pdf
    figsize = (10, 6)
    fig, ax = plt.subplots(figsize=figsize)
    ax.axis("off")
    table = ax.table(
        cellText=np.round(data[allcols][burnin:].describe().values.T, decimals=3),
        colLabels=data[allcols].describe().index,
        rowLabels=data[allcols].describe().columns,
        cellLoc="center",
        loc="center",
    )
    table.scale(1, 1.5)
    plt.title(f"Descriptive statistics (burning={burnin})")
    pdf.savefig(fig)
    plt.close(fig)


def plot_and_save(
    data,
    x=None,
    y=None,
    figsize=None,
    title=None,
    pngfile=None,
    pdf=None,
    remove_marg_x=False,
):
    # Generate a joint plot, save it to png, then append to pdf
    plt.figure()
    g = sns.jointplot(x=x, y=y, data=data)
    if remove_marg_x:
        g.ax_marg_x.remove()
    if title:
        g.fig.suptitle(title)
    if figsize:
        g.fig.set_figwidth(figsize[0])
        g.fig.set_figheight(figsize[1])
    if pngfile:
        g.savefig(pngfile)
    if pdf:
        pdf.savefig(g.fig)
    plt.close(g.fig)


def report_trace(data, cols, burnin, outdir, figsize, pdf):
    # Plot the trace and density for each col
    for col in cols:
        ess = calculate_ess(data[col], burnin=burnin)
        plot_and_save(
            data,
            x="state",
            y=col,
            figsize=figsize,
            title=f"{col} (ESS={ess:.1f})",
            pngfile=os.path.join(outdir, f"{col}_trace.png"),
            pdf=pdf,
            remove_marg_x=True,
        )


def report_joint(data, joint, outdir, figsize, pdf):
    # Plot the joint density for each pair of cols
    for pair in joint:
        plot_and_save(
            data,
            x=pair[0],
            y=pair[1],
            figsize=figsize,
            title=f"{pair[0]} vs {pair[1]}",
            pngfile=os.path.join(outdir, f"{pair[0]}_{pair[1]}_joint.png"),
            pdf=pdf,
            remove_marg_x=True,
        )


def report(filename, cols, joint, burnin, outdir, pdf_file):
    # Load the data
    data = pd.read_csv(filename, sep="\t", comment="#")

    # Compile figures to a single pdf
    pdf = PdfPages(pdf_file)

    # Defaults
    figsize = (10, 6)
    figsize_square = (figsize[1], figsize[1])
    cols = cols if cols else data.columns[1:]  # Exclude 'state' from visualisations

    # Generate report pages
    report_descriptives(data, cols, burnin, figsize, pdf)
    report_trace(data, cols, burnin, outdir, figsize, pdf)
    report_joint(data, joint, outdir, figsize_square, pdf)

    # Save all figures to a single pdf
    pdf.close()


if __name__ == "__main__":
    # Parse CLI arguments
    parser = argparse.ArgumentParser(description="Visualise a trace file")
    parser.add_argument("--filename", help="Filename of the trace file", required=True)
    parser.add_argument("--cols", help="Columns to visualise", default="")
    parser.add_argument("--joint", help="Joint visualisation", default="")
    parser.add_argument("--burnin", help="Burn-in period", type=int, default=0)
    parser.add_argument("--outdir", help="Output directory", default="plots")
    args = parser.parse_args()

    # Make output folder
    os.makedirs(args.outdir, exist_ok=True)

    # Extract arguments
    filename = args.filename
    cols = args.cols.replace(" ", "").split(",") if args.cols else []
    joint = (
        [pair.split(",") for pair in args.joint.replace(" ", "").split(";")]
        if args.joint
        else []
    )
    burnin = args.burnin
    outdir = args.outdir
    pdf_file = os.path.join(args.outdir, "output.pdf")

    # Generate the report
    report(filename, cols, joint, burnin, outdir, pdf_file)
